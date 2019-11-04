extends KinematicBody2D

export var gravity = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
var linear_velocity = Vector2()
const SIDING_CHANGE_SPEED = 10
export var walk_speed = 200
export var jump_speed = 600
export var fall_multiplier = 2
export var low_jump_multiplier = 2

onready var feet = [$Foot1, $Foot2]

func _ready():
    pass
    
func _physics_process(delta):
        # Gravity
    linear_velocity.x += delta * gravity.x
    if linear_velocity.y > 0:
        linear_velocity.y += gravity.y * fall_multiplier * delta
    elif linear_velocity.y < 0 and !Input.is_action_pressed("jump"):
        linear_velocity.y += gravity.y * low_jump_multiplier * delta
    else:
        linear_velocity.y += gravity.y * delta
#    var old_pos = position
    linear_velocity = move_and_slide(linear_velocity, FLOOR_NORMAL)
#    if old_pos != position:
#        emit_signal("moved")
    var on_floor = is_on_floor()
    
    # Horizontal movement
    var target_speed = 0
    if Input.is_action_pressed("ui_left"):
        target_speed = -1
    if Input.is_action_pressed("ui_right"):
        target_speed = 1
    target_speed *= walk_speed
    linear_velocity.x = lerp(linear_velocity.x, target_speed, 0.4)
    
    # Move feet
    if linear_velocity.x < 0 - SIDING_CHANGE_SPEED or linear_velocity.x > 0 + SIDING_CHANGE_SPEED:
        for i in feet.size():
            print(feet[0].position)
            var add = -25 if i%2 == 0 else 25
            feet[i].position.x = add + sin((position.x + add * 2) * 0.01) * 50# if i % 2 == 0 else cos(position.x * 0.01) * 50
            feet[i].position.y = cos((position.x + add) * 0.1) * 50# if i % 2 == 0 else sin(position.x * 0.01) * 50 
    
    # Jumping
    if on_floor and Input.is_action_just_pressed("jump"):
        linear_velocity.y -= jump_speed
