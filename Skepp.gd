extends KinematicBody2D

var velocity : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()
var mass : float = 1.0
var friction_coefficient : float = 1.0
var rotation_speed : float = 4.0
var speed : int = 20
var max_speed : int = 800

export var boost_mag : float = 1.0 setget set_boost_mag
var boost_len : int = 300
var boost_cool : bool = true

signal boost(line)
signal boosted

onready var state = States.SkeppIdle.new() setget _set_state

onready var boost_line = $BoostLine
onready var boost_line_cooloff = $BoostLine/CoolOff
onready var boost_audio = $Audio/Boost
onready var boost_line_tween = $BoostLine/Tween

onready var thrust_audio = $Audio/Thrust/AnimationPlayer

func apply_force(force : Vector2) -> void:
    force = force / mass
    acceleration += force
    
func get_boost_point() -> Vector2:
    return Vector2(boost_len * boost_mag, 0)
    
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
    position.x = wrapf(position.x, 0, size.x)
    position.y = wrapf(position.y, 0, size.y)

func _physics_process(delta) -> void:
    state.update(self, delta)
    
func _on_CoolOff_timeout():
    boost_cool = true
    
func set_boost_mag(value):
    boost_mag = value

func play_animation(animation):
    $Sprite/Anim.play(animation)

func _set_state(new_state):
    if state != null:
        state.exit(self)
    state = new_state
    new_state.enter(self)

func _on_Area2D_area_entered(area):
    print("area entered")
    print(area)
    pass # Replace with function body.


func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
    print("area shape enterd")
    pass # Replace with function body.
