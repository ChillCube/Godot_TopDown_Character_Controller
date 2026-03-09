# Godot TopDown Character Controller API Reference
Generated: 2026-03-09

A character controller for top down movement, such as for an RPG game

## Class: TopDownCharacter


### ⚙️ Inspector Variables
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **speed** | `float` | `500` | used to set the speed of the character |
| **acceleration** | `float` | `1` | used to set how fast the character goes from min to max speed |
| **deceleration** | `float` | `0.1 ` | used to set how fast the character goes from max to min speed |
| **--- DASH ---** | | | |
| **enable_dashing** | `bool` | `true` | used to enable or disable dashing |
| **dash_speed** | `float` | `5` | used to determine the speed of a dash |
| **dash_time** | `float` | `0.5` | used to determine how long a dash should start |
| **dash_falloff** | `float` | `0.3 ` | used to determine how quickly a dash should stop |
| **dash_timeout** | `float` | `0.5` | used to determine how long of a break there has to be between each dash |
| **dashes** | `int` | `1` | used to determine how many dashes the character can perform |
| **--- KNOCKBACK ---** | | | |
| **enable_knockback** | `bool` | `true` | this is used to enable and disable knockback |
| **knockback_speed** | `float` | `5` | used to determine how strong knockbacks should be |
| **knockback_time** | `float` | `0.5` | used to determine how long a knockback should last |
| **knockback_falloff** | `float` | `0.3 ` | used to determine how quickly a knockback should slow down |
| **--- CONTROLS ---** | | | |
| **input_dash** | `String` | `"dash" ` | this is used to set the input for dashing |
| **--- KEYBOARD ---** | | | |
| **input_left** | `String` | `"ui_left" ` | this is used to set the input for moving left |
| **input_right** | `String` | `"ui_right" ` | this is used to set the input for moving right |
| **input_down** | `String` | `"ui_down" ` | this is used to set the input for moving down |
| **input_up** | `String` | `"ui_up" ` | this is used to set the input for moving up |
| **--- CONTROLLER ---** | | | |
| **deadzone** | `float` | `0.1 ` | this is used to set the deadzone on the controller |

### 💾 Class Variables
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **dashes_used** | `int` | `0` | used to track how many dashes were used |
| **dash_vector** | `Vector2` | `Vector2.ZERO ` | used to track the direction and strength of a dash |
| **dash_timer** | `SceneTreeTimer` | `get_tree().create_timer(0)` | this sets the timer that is used for tracking how long the dash should be |
| **dash_timeout_timer** | `SceneTreeTimer` | `get_tree().create_timer(0)` | this sets the timer that is used for tracking the cooldown time in between dashes |
| **knockback_vector** | `Vector2` | `Vector2.ZERO ` | used to track the knockbacks speed and direction |
| **knockback_timer** | `SceneTreeTimer` | `get_tree().create_timer(0)` | this sets the timer that is used for tracking the knockbacks length |

---

