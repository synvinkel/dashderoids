extends Camera2D

# https://github.com/GDquest/2019-godot-kickstarter/blob/master/youtube-tutorial-demos/02-06-game-juice/levels/camera/ShakingCamera.gd

onready var timer : Timer = $Timer

export var amplitude : = 6.0
export var duration : = 0.8 setget set_duration
export(float, EASE) var DAMP_EASING : = 1.0
export var shake : = false setget set_shake

var enabled : = true


func _ready() -> void:
    randomize()
    var vp = get_viewport().size
    position = Vector2(vp.x / 2, vp.y / 2)
    set_process(false)
    self.duration = duration
    connect_to_shakers()


func _process(delta: float) -> void:
    var damping : = ease(timer.time_left / timer.wait_time, DAMP_EASING)
    offset = Vector2(
        rand_range(amplitude, -amplitude) * damping,
        rand_range(amplitude, -amplitude) * damping)


func _on_ShakeTimer_timeout() -> void:
    self.shake = false


func _on_camera_shake_requested() -> void:
    if not enabled:
        return
    self.shake = true


func set_duration(value: float) -> void:
    duration = value
    timer.wait_time = duration


func set_shake(value: bool) -> void:
    shake = value
    set_process(shake)
    offset = Vector2()
    if shake:
        timer.start()
    else:
        connect_to_shakers()

func connect_to_shakers() -> void:
    for camera_shaker in get_tree().get_nodes_in_group("camera_shaker"):
        camera_shaker.connect("camera_shake_requested", self, "_on_camera_shake_requested")