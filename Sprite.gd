extends Sprite

signal coin_picked_up(coin)

func _ready():
    $AnimationPlayer.play("spin")
    pass


func _on_Area2D_body_entered(body):
    print("from coin coin picked up")
    emit_signal("coin_picked_up", self)
    queue_free()
    pass # Replace with function body.
