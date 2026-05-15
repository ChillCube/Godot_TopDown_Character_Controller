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

@export var speed : float = 500:
	set(value):
		speed = value
		if _movement:
			_movement.speed = value
@export_range(0, 1) var acceleration : float = 1:
	set(value):
		acceleration = value
		if _movement:
			_movement.acceleration = value
@export_range(0, 1) var deceleration : float = 0.1:
	set(value):
		deceleration = value
		if _movement:
			_movement.deceleration = value

@export_group("Dash")
@export var enable_dashing : bool = true:
	set(value):
		enable_dashing = value
		if _movement:
			_movement.enable_dashing = value
@export var dash_speed : float = 5:
	set(value):
		dash_speed = value
		if _movement:
			_movement.dash_speed = value
@export var dash_time : float = 0.5:
	set(value):
		dash_time = value
		if _movement:
			_movement.dash_time = value
@export_range(0, 1) var dash_falloff : float = 0.3:
	set(value):
		dash_falloff = value
		if _movement:
			_movement.dash_falloff = value
@export var dash_timeout : float = 0.5:
	set(value):
		dash_timeout = value
		if _movement:
			_movement.dash_timeout = value
@export var dashes : int = 1:
	set(value):
		dashes = value
		if _movement:
			_movement.dashes = value

@export_group("Knockback")
@export var enable_knockback : bool = true:
	set(value):
		enable_knockback = value
		if _movement:
			_movement.enable_knockback = value
@export var knockback_speed : float = 5:
	set(value):
		knockback_speed = value
		if _movement:
			_movement.knockback_speed = value
@export var knockback_time : float = 0.5:
	set(value):
		knockback_time = value
		if _movement:
			_movement.knockback_time = value
@export_range(0, 1) var knockback_falloff : float = 0.3:
	set(value):
		knockback_falloff = value
		if _movement:
			_movement.knockback_falloff = value

@export_category("Controls")
@export var input_dash : String = "dash"

@export_group("Keyboard")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_down : String = "ui_down"
@export var input_up : String = "ui_up"

@export_group("Controller")
@export var deadzone : float = 0.1

@export_group("Multiplayer")
@export_range(1.0, 30.0, 0.5) var remote_lerp_speed : float = 15.0:
	set(value):
		remote_lerp_speed = value
		if _movement:
			_movement.remote_lerp_speed = value

# Components
var _movement : TopDownMovement

# Local input state
var _last_input_vector : Vector2 = Vector2.ZERO

func _ready():
	_create_movement_component()
	_connect_signals()
	
	# Setup multiplayer visibility
	if multiplayer.has_multiplayer_peer():
		if name.is_valid_int():
			set_multiplayer_authority(int(name))

func _create_movement_component():
	_movement = TopDownMovement.new()
	_movement.name = "TopDownMovement"
	
	# Copy all properties
	_movement.speed = speed
	_movement.acceleration = acceleration
	_movement.deceleration = deceleration
	_movement.enable_dashing = enable_dashing
	_movement.dash_speed = dash_speed
	_movement.dash_time = dash_time
	_movement.dash_falloff = dash_falloff
	_movement.dash_timeout = dash_timeout
	_movement.dashes = dashes
	_movement.enable_knockback = enable_knockback
	_movement.knockback_speed = knockback_speed
	_movement.knockback_time = knockback_time
	_movement.knockback_falloff = knockback_falloff
	_movement.remote_lerp_speed = remote_lerp_speed
	
	add_child(_movement)

func _connect_signals():
	# Forward all movement signals
	_movement.connect("moving", Callable(self, "_on_moving"))
	_movement.connect("started_dashing", Callable(self, "_on_started_dashing"))
	_movement.connect("used_a_dash", Callable(self, "_on_used_a_dash"))
	_movement.connect("stopped_dashing", Callable(self, "_on_stopped_dashing"))
	_movement.connect("moving_up", Callable(self, "_on_moving_up"))
	_movement.connect("moving_down", Callable(self, "_on_moving_down"))
	_movement.connect("moving_left", Callable(self, "_on_moving_left"))
	_movement.connect("moving_right", Callable(self, "_on_moving_right"))
	_movement.connect("stopped_moving", Callable(self, "_on_stopped_moving"))
	_movement.connect("knocked_back", Callable(self, "_on_knocked_back"))
	_movement.connect("knockback_stopped", Callable(self, "_on_knockback_stopped"))

func _physics_process(delta: float):
	# Always collect input (even on remote instances, but movement component will reject it)
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	input_vector.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
	
	var joy_stick_strength : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if joy_stick_strength.length() > deadzone:
		input_vector = joy_stick_strength
	
	input_vector = input_vector.normalized()
	_last_input_vector = input_vector
	
	# Send movement request to movement component (will be rejected if not authority)
	if input_vector != Vector2.ZERO:
		_movement.request_movement(input_vector)
	else:
		_movement.request_movement(Vector2.ZERO)
	
	# Handle dash
	if enable_dashing and Input.is_action_just_pressed(input_dash):
		_movement.request_dash(input_vector)

# Public API for external control (NPCs, AI, State Machines)
func set_movement_override(direction: Vector2):
	if _movement:
		_movement.request_movement(direction)

func clear_movement_override():
	if _movement:
		_movement.request_movement(Vector2.ZERO)

func try_dash(direction: Vector2) -> void:
	if _movement:
		_movement.request_dash(direction)

func apply_knockback(direction: Vector2, strength: float):
	if _movement:
		_movement.request_knockback(direction, strength)

# Signal handlers (just forward to player signals)
func _on_moving(direction_and_speed: Vector2):
	emit_signal("moving", direction_and_speed)

func _on_started_dashing(direction_and_speed: Vector2):
	emit_signal("started_dashing", direction_and_speed)

func _on_used_a_dash(dashes_left: int, dashes_used: int, max_dashes: int):
	emit_signal("used_a_dash", dashes_left, dashes_used, max_dashes)

func _on_stopped_dashing():
	emit_signal("stopped_dashing")

func _on_moving_up():
	emit_signal("moving_up")

func _on_moving_down():
	emit_signal("moving_down")

func _on_moving_left():
	emit_signal("moving_left")

func _on_moving_right():
	emit_signal("moving_right")

func _on_stopped_moving():
	emit_signal("stopped_moving")

func _on_knocked_back(direction: Vector2, strength: float):
	emit_signal("knocked_back", direction, strength)

func _on_knockback_stopped():
	emit_signal("knockback_stopped")
