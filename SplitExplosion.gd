extends Node2D

func _ready():
    print("ready")
    print("position")

func _on_Timer_timeout():
    $Particles2D.emitting = false
    $FreeTimer.start()

func init(_position):
    print("got position")
    print(_position)
    position = _position

func _on_FreeTimer_timeout():
    queue_free()
