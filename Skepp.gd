extends KinematicBody2D

var velocity : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()
var mass : float = 1.0
var friction_coefficient : float = 1.0
var rotation_dir : int = 0
var rotation_speed : float = 4.0
var speed : int = 20
var max_speed : int = 800

export var boost_mag : float = 1.0 setget set_boost_mag
var boost_len : int = 300
var boost_cool : bool = true

signal boost(line)
signal boosted

enum {
    IDLE,
    THRUSTING
    BOOSTING,
    BOOSTED
}

var state = IDLE    

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

func enter_BOOSTING():
    if boost_cool:
       state = BOOSTING
       boost_mag = 0        
       $BoostLine/Tween.interpolate_property(self, "boost_mag", 0.0, 1.0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
       $BoostLine/Tween.start()

func enter_THRUSTING():
   $Audio/Thrust.play()    
   state = THRUSTING 

func get_input() -> void:
    # State specifics
    match state:
        IDLE:
            if Input.is_action_just_pressed("boost"):
                enter_BOOSTING()
                
        BOOSTING:
            if Input.is_action_just_released("boost"):
                state = BOOSTED
            
    # Common for all states
    rotation_dir = 0
    if Input.is_action_pressed("turn_left"):
        rotation_dir -= 1
    if Input.is_action_pressed("turn_right"):
        rotation_dir += 1
    if Input.is_action_pressed("thrust"):
        apply_force(Vector2(speed, 0).rotated(rotation))
    if Input.is_action_just_pressed("thrust"):
        $Audio/Thrust/AnimationPlayer.play("fade_in")
    if Input.is_action_just_released("thrust"):
        $Audio/Thrust/AnimationPlayer.play("fade_out")
        
        

#
func _physics_process(delta) -> void:

    get_input()
    
    match state:     
        BOOSTING:
            $BoostLine.points = [Vector2(), Vector2(boost_len * boost_mag, 0)]
            emit_signal("boost", [global_position, global_position + Vector2(boost_len * boost_mag, 0).rotated(rotation)])
            $BoostLine.visible = true
                
        BOOSTED:
            $BoostLine.visible = false
            $BoostLine.points = []
            boost_cool = false
            position += Vector2(boost_len * boost_mag, 0).rotated(rotation)
            boost_mag = 0
            $BoostLine/CoolOff.start()
            $Audio/Boost.play()
            emit_signal("boosted")
            state = IDLE
    
    # Physics
    rotation += rotation_dir * rotation_speed * delta
    apply_friction()
    velocity += acceleration
    velocity = velocity.clamped(max_speed)
    var collision_info = move_and_collide(velocity * delta)
    acceleration *= 0
    
    wrap_around()
    

func _on_CoolOff_timeout():
    boost_cool = true
    
func set_boost_mag(value):
    boost_mag = value