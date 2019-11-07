extends KinematicBody2D

var velocity : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()
var mass : float = 1.0
var friction_coefficient : float = 1.0
var rotation_dir : int = 0
var rotation_speed : float = 3.0
var speed : int = 10
var max_speed : int = 200

var thrusting : bool = false
var boosting : bool = false

export var boost_mag : float = 1.0
var boost_len : int = 300
var boost_cool : bool = true

var shape : Array = [Vector2(-20, -20), Vector2(30, 0), Vector2(-20, 20)]

func _ready() -> void:
    $CollisionPolygon.polygon = shape
    update()

func _draw() -> void:
    draw_polygon(shape, [Cols.pink])
    
func apply_force(force : Vector2) -> void:
    force = force / mass
    acceleration += force
    
func apply_friction() -> void:
    var normal : float = 1.0
    var frictionMag : float = friction_coefficient * normal
    var friction : Vector2 = velocity
    friction *= -1
    friction = friction.normalized()
    friction *= frictionMag
    apply_force(friction)

func get_input() -> void:
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
    if Input.is_action_just_pressed("boost") and boost_cool:
        boosting = true
        boost_mag = 0        
        $BoostLine/Tween.interpolate_property(self, "boost_mag", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
        $BoostLine/Tween.start()
    if Input.is_action_just_released("boost") and boosting:
        boost_cool = false
        position += Vector2(boost_len * boost_mag, 0).rotated(rotation)
        boost_mag = 0
        boosting = false
        $BoostLine/CoolOff.start()
        
func wrap_around() -> void:
    var size : Vector2 = get_viewport().size
    if position.x > size.x:
        position.x = 0
    if position.y > size.y:
        position.y = 0
    if position.x < 0:
        position.x = size.x
    if position.y < 0:
        position.y = size.y
    
    
func _physics_process(delta) -> void:

    get_input()
    rotation += rotation_dir * rotation_speed * delta

    apply_friction()
    
    if boosting:
        var t = get_global_transform()
        $BoostLine.points = [t.xform_inv(position), Vector2(boost_len * boost_mag, 0)]
        $BoostLine.visible = true
    else:
        $BoostLine.visible = false
        $BoostLine.points = []
        
    
    velocity += acceleration
    velocity = velocity.clamped(max_speed)
    var collision_info = move_and_collide(velocity * delta)
    acceleration *= 0
    
    wrap_around()
    update()
    

func _on_CoolOff_timeout():
    boost_cool = true
