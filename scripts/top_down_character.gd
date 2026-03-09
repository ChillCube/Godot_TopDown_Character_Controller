extends CharacterBody2D
class_name TopDownCharacter

signal moving(direction_and_speed : Vector2) ## emitted when the character moves, returns direction and speed as a single vector (length = speed)
signal started_dashing(direction_and_speed : Vector2) ## emitted when the character is dashing. Returns directiona nd speed as a single vector (length = speed)
signal used_a_dash(dashes_left : int, dashes_used : int, max_dashes : int) ## emitted when the character dashes. Returns the amount of dashes left and the maximum dashes
signal stopped_dashing ## emitted when the character stops dashing

signal moving_up ## emitted when the character moves up / north
signal moving_down ## emitted when the character moves down / south
signal moving_left ## emitted when the character moves left / west
signal moving_right ## emitted when the character moves right / east

signal stopped_moving ## emitted when the character stops moving

signal knocked_back(direction : Vector2 , strength : float) ## emitted when the character is knocked back (return direction and strength)
signal knockback_stopped ## emitted when the characters knockback stopped

@export var speed : float = 500; ## used to set the speed of the character
@export_range(0, 1) var acceleration : float = 1; ## used to set how fast the character goes from min to max speed
@export_range(0, 1) var deceleration : float = 0.1 ## used to set how fast the character goes from max to min speed

@export_group("Dash")
@export var enable_dashing : bool = true; ## used to enable or disable dashing
@export var dash_speed : float = 5; ## used to determine the speed of a dash
@export var dash_time : float = 0.5; ## used to determine how long a dash should start
@export_range(0, 1) var dash_falloff : float = 0.3 ## used to determine how quickly a dash should stop
@export var dash_timeout : float = 0.5; ## used to determine how long of a break there has to be between each dash
@export var dashes : int = 1; ## used to determine how many dashes the character can perform
var dashes_used : int = 0; ## used to track how many dashes were used
var dash_vector : Vector2 = Vector2.ZERO ## used to track the direction and strength of a dash
@onready var dash_timer : SceneTreeTimer = get_tree().create_timer(0); ## this sets the timer that is used for tracking how long the dash should be
@onready var dash_timeout_timer : SceneTreeTimer = get_tree().create_timer(0); ## this sets the timer that is used for tracking the cooldown time in between dashes

@export_group("Knockback")
@export var enable_knockback : bool = true; ## this is used to enable and disable knockback
@export var knockback_speed : float = 5; ## used to determine how strong knockbacks should be
@export var knockback_time : float = 0.5; ## used to determine how long a knockback should last
@export_range(0, 1) var knockback_falloff : float = 0.3 ## used to determine how quickly a knockback should slow down
var knockback_vector : Vector2 = Vector2.ZERO ## used to track the knockbacks speed and direction
@onready var knockback_timer : SceneTreeTimer = get_tree().create_timer(0); ## this sets the timer that is used for tracking the knockbacks length

@export_category("Controls")
@export var input_dash : String = "dash" ## this is used to set the input for dashing

@export_group("Keyboard")
@export var input_left : String = "ui_left" ## this is used to set the input for moving left
@export var input_right : String = "ui_right" ## this is used to set the input for moving right
@export var input_down : String = "ui_down" ## this is used to set the input for moving down
@export var input_up : String = "ui_up" ## this is used to set the input for moving up

@export_group("Controller")
@export var deadzone : float = 0.1 ## this is used to set the deadzone on the controller

var speed_vector : Vector2 = Vector2(0,0);
var acceleration_vector : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var max_speed = speed
	
	#region GET DIRECTIONAL INPUTS

	var input_vector : Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength(input_right) - Input.get_action_strength(input_left)
	input_vector.y = Input.get_action_strength(input_down) - Input.get_action_strength(input_up)
	
	var joy_stick_strength : Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	if joy_stick_strength.length() > deadzone:
		input_vector = joy_stick_strength;

	input_vector = input_vector.normalized()

#endregion
	
	#region DASH
	if enable_dashing:
		if Input.is_action_just_pressed(input_dash):
			if dash_timeout_timer.time_left < 0.1:
				dashes_used = 0;
			if dashes_used < dashes:
				emit_signal("started_dashing", input_vector)
				emit_signal("used_a_dash", dashes - dashes_used, dashes_used, dashes)
				dash_vector = (input_vector * dash_speed *200);
				dash_timer = get_tree().create_timer(dash_time)
				dash_timeout_timer = get_tree().create_timer(dash_timeout)
				dashes_used += 1;
		if dash_timer.time_left < 0.01:
			dash_vector += (Vector2(0,0) - dash_vector) * dash_falloff
			if dash_vector.length() < 1:
				emit_signal("stopped_dashing")

	#endregion
	
	var max_speed_vector = input_vector * max_speed 
	var deceleration_vector = (Vector2.ZERO - speed_vector) * deceleration
	var acceleration_vector : Vector2;
	if input_vector.length() > 0:
		acceleration_vector = ((max_speed_vector - speed_vector) * acceleration) + (input_vector * deceleration_vector.length())
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

func knockback(direction: Vector2, strength : float) -> void: ## This can be used by other nodes to start knockback
	emit_signal("knocked_back", direction, strength)
	if enable_knockback:
		knockback_vector = (direction.normalized() * knockback_speed * 200 * strength);
		knockback_timer = get_tree().create_timer(knockback_time)
	if knockback_timer.time_left < 0.01:
		knockback_vector += (Vector2(0,0) - knockback_vector) * knockback_falloff
		if knockback_vector.length() < 0.1:
			emit_signal("knockback_stopped")


func emit_direction() -> void:
	if velocity.length() == 0:
		return

	var angle = velocity.angle()
	var direction_string : String
	
	if angle >= -PI/4 and angle < PI/4:
		emit_signal("moving_right")
	elif angle >= PI/4 and angle < 3 * PI/4:
		emit_signal("moving_down")
	elif angle >= 3 * PI/4 or angle < -3 * PI/4:
		emit_signal("moving_left")
	else: # angle >= -3 * PI/4 and angle < -PI/4
		emit_signal("moving_up")
