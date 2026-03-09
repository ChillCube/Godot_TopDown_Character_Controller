# Godot_TopDown_Character_Controller API Reference
Generated: 2026-03-09

A character controller for top down movement, such as for an RPG game

## Class: TopDownCharacter
**Inherits:** [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)


### ⚙️ Inspector Variables
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **speed** | `float` | `500 ## used to set the speed of the character` | used to set the speed of the character |
| **acceleration** | `float` | `1 ## used to set how fast the character goes from min to max speed` | used to set how fast the character goes from min to max speed |
| **deceleration** | `float` | `0.1 ## used to set how fast the character goes from max to min speed` | used to set how fast the character goes from max to min speed |
| **enable_dashing** | `bool` | `true ## used to enable or disable dashing` | used to enable or disable dashing |
| **dash_speed** | `float` | `5 ## used to determine the speed of a dash` | used to determine the speed of a dash |
| **dash_time** | `float` | `0.5 ## used to determine how long a dash should start` | used to determine how long a dash should start |
| **dash_falloff** | `float` | `0.3 ## used to determine how quickly a dash should stop` | used to determine how quickly a dash should stop |
| **dash_timeout** | `float` | `0.5 ## used to determine how long of a break there has to be between each dash` | used to determine how long of a break there has to be between each dash |
| **dashes** | `int` | `1 ## used to determine how many dashes the character can perform` | used to determine how many dashes the character can perform |
| **enable_knockback** | `bool` | `true ## this is used to enable and disable knockback` | this is used to enable and disable knockback |
| **knockback_speed** | `float` | `5 ## used to determine how strong knockbacks should be` | used to determine how strong knockbacks should be |
| **knockback_time** | `float` | `0.5 ## used to determine how long a knockback should last` | used to determine how long a knockback should last |
| **knockback_falloff** | `float` | `0.3 ## used to determine how quickly a knockback should slow down` | used to determine how quickly a knockback should slow down |
| **input_dash** | `String` | `"dash" ## this is used to set the input for dashing` | this is used to set the input for dashing |
| **input_left** | `String` | `"ui_left" ## this is used to set the input for moving left` | this is used to set the input for moving left |
| **input_right** | `String` | `"ui_right" ## this is used to set the input for moving right` | this is used to set the input for moving right |
| **input_down** | `String` | `"ui_down" ## this is used to set the input for moving down` | this is used to set the input for moving down |
| **input_up** | `String` | `"ui_up" ## this is used to set the input for moving up` | this is used to set the input for moving up |
| **deadzone** | `float` | `0.1 ## this is used to set the deadzone on the controller` | this is used to set the deadzone on the controller |

### 🔔 Signals
| Signal | Arguments | Description |
| :--- | :--- | :--- |
| **moving** | direction_and_speed | emitted when the character moves, returns direction and speed as a single vector (length = speed) |
| **started_dashing** | direction_and_speed | emitted when the character is dashing. Returns directiona nd speed as a single vector (length = speed) |
| **used_a_dash** | dashes_left | emitted when the character dashes. Returns the amount of dashes left and the maximum dashes |
| **stopped_dashing** | - | emitted when the character stops dashing |
| **moving_up** | - | emitted when the character moves up / north |
| **moving_down** | - | emitted when the character moves down / south |
| **moving_left** | - | emitted when the character moves left / west |
| **moving_right** | - | emitted when the character moves right / east |
| **stopped_moving** | - | emitted when the character stops moving |
| **knocked_back** | direction | emitted when the character is knocked back (return direction and strength) |
| **knockback_stopped** | - | emitted when the characters knockback stopped |

### 🛠️ Methods
| Method | Arguments | Returns | Description |
| :--- | :--- | :--- | :--- |
| **knockback()** | direction: Vector2<br> strength : float | `void` | This can be used by other nodes to start knockback |
| **emit_direction()** | - | `void` | - |

---

