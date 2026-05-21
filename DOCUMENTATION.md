# Godot_TopDown_Character_Controller API Reference
Generated: 2026-05-21

A character controller for top down movement, such as for an RPG game

## Class: TopDownCharacter
**Inherits:** [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)


### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **speed** | `float` | `500` | Maximum movement speed in pixels/sec |
| **acceleration** | `float` | `1` | How quickly the character ramps up to full speed (1 = instant) |
| **deceleration** | `float` | `0.1` | How quickly the character slows to a stop (1 = instant) |
| **enable_dashing** | `bool` | `true` | Allow the character to dash |
| **dash_speed** | `float` | `5` | Speed multiplier applied during a dash |
| **dash_time** | `float` | `0.5` | Duration in seconds of a single dash |
| **dash_falloff** | `float` | `0.3` | How quickly dash velocity decays after the timer ends |
| **dash_timeout** | `float` | `0.5` | Cooldown in seconds between consecutive dashes |
| **dashes** | `int` | `1` | How many dashes the character can perform before the cooldown resets |
| **enable_knockback** | `bool` | `true` | Allow the character to be knocked back by apply_knockback() |
| **knockback_speed** | `float` | `5` | Speed multiplier for knockback velocity |
| **knockback_time** | `float` | `0.5` | Duration in seconds that knockback is applied |
| **knockback_falloff** | `float` | `0.3` | How quickly knockback velocity decays after the timer ends |
| **input_dash** | `String` | `"dash"` | Input action name for dashing |
| **input_left** | `String` | `"ui_left"` | Input action name for moving left |
| **input_right** | `String` | `"ui_right"` | Input action name for moving right |
| **input_down** | `String` | `"ui_down"` | Input action name for moving down |
| **input_up** | `String` | `"ui_up"` | Input action name for moving up |
| **deadzone** | `float` | `0.1` | Analog stick dead zone to ignore drift |
| **remote_lerp_speed** | `float` | `15.0` | Lerp speed used to interpolate remote player positions on non-authority clients |

### 🔔 Signals
| Signal | Arguments | Description |
| :--- | :--- | :--- |
| **func _ready** | `` |  Creates the TopDownMovement component, connects its signals, and sets multiplayer authority from node name |

### 🛠️ Methods
| Method | Arguments | Returns | Description |
| :--- | :--- | :--- | :--- |
| **set_movement_override()** | `direction: Vector2` | `void` |  External API (AI/NPC): push a movement direction without needing input |
| **clear_movement_override()** | - | `void` |  External API: stop any override-driven movement |
| **try_dash()** | `direction: Vector2` | `void` |  External API: trigger a dash in the given direction (e.g. from AI or state machine) |
| **apply_knockback()** | `direction: Vector2`<br>`strength: float` | `void` |  External API: apply knockback to the character (direction is normalized internally) |

---

