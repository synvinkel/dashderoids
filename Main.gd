extends Node2D

var game_started : bool = false

func _ready():
    var v = get_viewport().size
    $Game/Polygon.position = Vector2(v.x / 2, v.y /2)
    
func pause() -> void:
    if get_tree().paused:
        get_tree().paused = false
        $StartScreen.visible = false
    else:
        get_tree().paused = true
        $StartScreen.visible = true
    
func _process(delta):
    if game_started and Input.is_action_just_pressed("ui_cancel"):
        pause()
    if Input.is_action_just_pressed("restart"):
        get_tree().reload_current_scene()
        
func quit_game():
    get_tree().quit()
    
func start_game():
    if game_started:
        pause()
    else:
        game_started = true
        $StartScreen.visible = false        
        $Game/Skepp.playing = true