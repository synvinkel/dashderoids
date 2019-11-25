extends Node2D

func _ready():
    pass

func _physics_process(delta):
    $KinematicBody2D.position = get_global_mouse_position()

func _on_Area2D_body_entered(body):
    print("entered")
    print(body)
    pass # Replace with function body.
