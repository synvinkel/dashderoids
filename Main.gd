extends Node2D

func _ready():
    var v = get_viewport().size
    $Polygon.position = Vector2(v.x / 2, v.y /2)
    
func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().reload_current_scene()
        
func quit_game():
    get_tree().quit()
    
func start_game():
    $StartScreen.visible = false
    $Skepp.playing = true