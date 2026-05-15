extends CharacterBody2D
class_name TopDownCharacter

signal moving(direction_and_speed : Vector2)
signal started_dashing(direction_and_speed : Vector2)
signal used_a_dash(dashes_left : int, dashes_used : int, max_dashes : int)
signal stopped_dashing

signal moving_up
signal moving_down
signal moving_left
signal moving_right

signal stopped_moving

signal knocked_back(direction : Vector2 , strength : float)
signal knockback_stopped

@export var speed : float = 500;
@export_range(0, 1) var acceleration : float = 1;
@export_range(0, 1) var deceleration : float = 0.1

@export_group("Dash")
@export var enable_dashing : bool = true;
@export var dash_speed : float = 5;
@export var dash_time : float = 0.5;
@export_range(0, 1) var dash_falloff : float = 0.3
@export var dash_timeout : float = 0.5;
@export var dashes : int = 1;
var dashes_used : int = 0;
var dash_vector : Vector2 = Vector2.ZERO
@onready var dash_timer : SceneTreeTimer = get_tree().create_timer(0);
@onready var dash_timeout_timer : SceneTreeTimer = get_tree().create_timer(0);

@export_group("Knockback")
@export var enable_knockback : bool = true;
@export var knockback_speed : float = 5;
@export var knockback_time : float = 0.5;
@export_range(0, 1) var knockback_falloff : float = 0.3
var knockback_vector : Vector2 = Vector2.ZERO
@onready var knockback_timer : SceneTreeTimer = get_tree().create_timer(0);

@export_category("Controls")
@export var input_dash : String = "dash"

@export_group("Keyboard")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_down : String = "ui_down"
@export var input_up : String = "ui_up"

@export_group("Controller")
@export var deadzone : float = 0.1

# New variable to control if this character accepts player input
@export var is_player : bool = true

var speed_vector : Vector2 = Vector2(0,0);
var acceleration_vector : Vector2 = Vector2.ZERO

# Multiplayer detection
var _is_in_multiplayer : bool = false
var _is_local_player : bool = true
var _input_vector : Vector2 = Vector2.ZERO
var _is_dashing : bool = false
var _dash_timer_start : float = 0.0
var _is_knocked_back : bool = false
var _knockback_timer_start : float = 0.0
# Network interpolation — updated via lobby position broadcast (SteamManager)
var _net_position : Vector2 = Vector2.ZERO
@export_range(1.0, 30.0, 0.5) var remote_lerp_speed : float = 15.0

func _ready():
	_is_in_multiplayer = multiplayer.has_multiplayer_peer()
	_net_position = position

	if _is_in_multiplayer:
		# Node name is the Godot peer ID (set by SteamManager._add_player)
		if name.is_valid_int():
			set_multiplayer_authority(int(name))

		_is_local_player = (multiplayer.get_unique_id() == get_multiplayer_authority())

		if not _is_local_player:
			# Keep _process enabled for remote interpolation; disable physics only
			set_physics_process(false)
	else:
		set_multiplayer_authority(1)
		set_process(true)
		set_physics_process(true)
		_is_local_player = true

func _physics_process(delta: float) -> void:
	# Check if we should process this character
	if _is_in_multiplayer and not is_multiplayer_authority():
		return
	
	var max_speed = speed
	
	#region GET DIRECTIONAL INPUTS
	var input_vector : Vector2 = Vector2.ZERO
	
	# Only get input if this is a player-controlled character
	if is_player and (not _is_in_multiplayer or _is_local_player):
		input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
		input_vector.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
		
		var joy_stick_strength : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		if joy_stick_strength.length() > deadzone:
			input_vector = joy_stick_strength;
		
		input_vector = input_vector.normalized()
		
		if _is_in_multiplayer:
			_input_vector = input_vector
	else:
		input_vector = _input_vector
	#endregion
	
	#region DASH
	if enable_dashing:
		# Only allow dash input if this is a player character
		if is_player and (not _is_in_multiplayer or _is_local_player):
			if Input.is_action_just_pressed(input_dash):
				if _is_in_multiplayer:
					rpc("_try_dash", input_vector)
				else:
					_try_dash_singleplayer(input_vector)
		
		if _is_in_multiplayer and _is_dashing:
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - _dash_timer_start >= dash_time:
				_is_dashing = false
				dash_vector += (Vector2(0,0) - dash_vector) * dash_falloff
				if dash_vector.length() < 1:
					emit_signal("stopped_dashing")
					if _is_in_multiplayer:
						rpc("_sync_stop_dashing")
		elif not _is_in_multiplayer and dash_timer.time_left < 0.01:
			dash_vector += (Vector2(0,0) - dash_vector) * dash_falloff
			if dash_vector.length() < 1:
				emit_signal("stopped_dashing")
	#endregion
	
	# Process movement
	var current_input = input_vector if not _is_in_multiplayer else _input_vector
	var max_speed_vector = current_input * max_speed 
	var deceleration_vector = (Vector2.ZERO - speed_vector) * deceleration
	var acceleration_vector : Vector2;
	
	if current_input.length() > 0:
		acceleration_vector = ((max_speed_vector - speed_vector) * acceleration) + (current_input * deceleration_vector.length())
	else:
		acceleration_vector = Vector2.ZERO
		if speed_vector.length() < max_speed * 0.1:
			emit_signal("stopped_moving")
	
	speed_vector += acceleration_vector + deceleration_vector;
	velocity = speed_vector + dash_vector + knockback_vector
	
	if velocity.length() > 0:
		emit_signal("moving", velocity)
	
	move_and_slide()
	emit_direction()

	# Process knockback for multiplayer
	if _is_in_multiplayer:
		_process_knockback(delta)
	else:
		_process_singleplayer_knockback(delta)

func _process(delta: float) -> void:
	if _is_in_multiplayer and not _is_local_player:
		position = position.lerp(_net_position, delta * remote_lerp_speed)

func _try_dash_singleplayer(input_vector: Vector2):
	# Prevent NPCs from dashing
	if not is_player:
		return
		
	if dash_timeout_timer.time_left < 0.1:
		dashes_used = 0;
	
	if dashes_used < dashes:
		emit_signal("started_dashing", input_vector)
		emit_signal("used_a_dash", dashes - dashes_used, dashes_used, dashes)
		dash_vector = (input_vector * dash_speed * 200);
		dash_timer = get_tree().create_timer(dash_time)
		dash_timeout_timer = get_tree().create_timer(dash_timeout)
		dashes_used += 1;

@rpc("any_peer", "reliable", "call_local")
func _try_dash(input_vector: Vector2):
	# Prevent NPCs from initiating dash through RPC
	if not is_player:
		return
		
	if not _is_in_multiplayer:
		return
	
	var sender = multiplayer.get_remote_sender_id()
	if sender != 0 and sender != get_multiplayer_authority():
		return
	
	if dash_timeout_timer.time_left < 0.1:
		dashes_used = 0;
	
	if dashes_used < dashes:
		emit_signal("started_dashing", input_vector)
		emit_signal("used_a_dash", dashes - dashes_used, dashes_used, dashes)
		
		dash_vector = (input_vector * dash_speed * 200);
		_is_dashing = true
		_dash_timer_start = Time.get_ticks_msec() / 1000.0
		dash_timeout_timer = get_tree().create_timer(dash_timeout)
		dashes_used += 1;
		
		rpc("_sync_dash_state", dash_vector, _is_dashing, dashes_used, _dash_timer_start)

@rpc("authority", "reliable")
func _sync_dash_state(d_vec: Vector2, is_dashing: bool, d_used: int, start_time: float):
	if not _is_in_multiplayer:
		return
	dash_vector = d_vec
	_is_dashing = is_dashing
	dashes_used = d_used
	_dash_timer_start = start_time

@rpc("authority", "reliable")
func _sync_stop_dashing():
	if not _is_in_multiplayer:
		return
	_is_dashing = false
	emit_signal("stopped_dashing")

func knockback(direction: Vector2, strength : float) -> void:
	if _is_in_multiplayer:
		if not is_multiplayer_authority():
			rpc_id(get_multiplayer_authority(), "_knockback_from_remote", direction, strength)
			return
		
		emit_signal("knocked_back", direction, strength)
		if enable_knockback:
			_is_knocked_back = true
			_knockback_timer_start = Time.get_ticks_msec() / 1000.0
			knockback_vector = (direction.normalized() * knockback_speed * 200 * strength);
			rpc("_sync_knockback_state", knockback_vector, true)
	else:
		emit_signal("knocked_back", direction, strength)
		if enable_knockback:
			knockback_vector = (direction.normalized() * knockback_speed * 200 * strength);
			knockback_timer = get_tree().create_timer(knockback_time)

@rpc("any_peer", "reliable")
func _knockback_from_remote(direction: Vector2, strength: float):
	if not _is_in_multiplayer:
		return
	knockback(direction, strength)

@rpc("authority", "reliable")
func _sync_knockback_state(kb_vector: Vector2, is_kb: bool):
	if not _is_in_multiplayer:
		return
	knockback_vector = kb_vector
	_is_knocked_back = is_kb
	if is_kb:
		_knockback_timer_start = Time.get_ticks_msec() / 1000.0

func _process_knockback(delta: float) -> void:
	if not _is_in_multiplayer or not _is_knocked_back:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - _knockback_timer_start >= knockback_time:
		knockback_vector += (Vector2(0,0) - knockback_vector) * knockback_falloff
		if knockback_vector.length() < 0.1:
			_is_knocked_back = false
			emit_signal("knockback_stopped")
			rpc("_sync_knockback_state", Vector2.ZERO, false)

func _process_singleplayer_knockback(delta: float) -> void:
	if _is_in_multiplayer:
		return
	
	if knockback_timer.time_left < 0.01:
		knockback_vector += (Vector2(0,0) - knockback_vector) * knockback_falloff
		if knockback_vector.length() < 0.1:
			emit_signal("knockback_stopped")

func emit_direction() -> void:
	if velocity.length() == 0:
		return

	var angle = velocity.angle()
	
	if angle >= -PI/4 and angle < PI/4:
		emit_signal("moving_right")
	elif angle >= PI/4 and angle < 3 * PI/4:
		emit_signal("moving_down")
	elif angle >= 3 * PI/4 or angle < -3 * PI/4:
		emit_signal("moving_left")
	else:
		emit_signal("moving_up")
