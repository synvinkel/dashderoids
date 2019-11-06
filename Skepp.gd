extends KinematicBody2D

var velocity : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()
var mass : float = 1.0
var friction_coefficient : float = 1.0
var rotation_dir : int = 0
var rotation_speed : float = 3.0
var speed : int = 10
var max_speed : int = 200

var boosting : bool = false
var thrusting : bool = false

var boost_mag : float = 1.0
var boost_len : int = 300
var time_scale : float = 1.0

var shape : Array = [Vector2(-20, -20), Vector2(30, 0), Vector2(-20, 20)]

func _ready():
    $CollisionPolygon2D.polygon = shape
    update()

func _draw():
    draw_polygon(shape, [Cols.pink])
    if boosting:
        draw_line(Vector2(), Vector2(boost_len * boost_mag, 0), Cols.blue, 2.0, true)
    
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
        thrusting = true
        apply_force(Vector2(speed, 0).rotated(rotation))
    else:
        thrusting = false
    if Input.is_action_just_pressed("boost"):
        boosting = true
        time_scale = 0.5
    if Input.is_action_just_released("boost"):
        position += Vector2(boost_len * boost_mag, 0).rotated(rotation)
        boosting = false
        time_scale = 1.0
        
        
func wrap_around():
    var size : Vector2 = get_viewport().size
    if position.x > size.x:
        position.x = 0
    if position.y > size.y:
        position.y = 0
    if position.x < 0:
        position.x = size.x
    if position.y < 0:
        position.y = size.y
    
    
func _physics_process(delta):
    
    get_input()
    rotation += rotation_dir * rotation_speed * delta

    apply_friction()
    
    velocity += acceleration
    velocity = velocity.clamped(max_speed)
    var collision_info = move_and_collide(velocity * delta * time_scale)
    acceleration *= 0
    
    wrap_around()
    update()
    