extends Node2D

func _ready():
    print("ready")
    print("position")

func _on_Timer_timeout():
    $Particles2D.emitting = false

func init(_position):
    print("got position")
    print(_position)
    position = _position