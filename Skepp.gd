extends KinematicBody2D

var velocity : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()
var mass : float = 1.0
var friction_coefficient : float = 1.0
var rotation_dir : int = 0
var rotation_speed : float = 3.0
var speed : int = 10
var max_speed : int = 200

func _ready():
    pass
    
func apply_force(force : Vector2):
    force = force / mass
    acceleration += force
    
func apply_friction():
    var normal : float = 1.0
    var frictionMag : float = friction_coefficient * normal
    var friction : Vector2 = velocity
    friction *= -1
    friction = friction.normalized()
    friction *= frictionMag
    apply_force(friction)

func get_input():
    rotation_dir = 0
    if Input.is_action_pressed("turn_left"):
        rotation_dir -= 1
    if Input.is_action_pressed("turn_right"):
        rotation_dir += 1
    if Input.is_action_pressed("thrust"):
        apply_force(Vector2(speed, 0).rotated(rotation))
    
func _physics_process(delta):
    
    get_input()
    rotation += rotation_dir * rotation_speed * delta

    apply_friction()
    
    velocity += acceleration
    velocity = velocity.clamped(max_speed)
    var collision_info = move_and_collide(velocity * delta)
    
    acceleration *= 0