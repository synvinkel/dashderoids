extends Node2D

var paused : bool = false setget pause_game

func _ready():
    var v = get_viewport().size
    $Game/Polygon.position = Vector2(v.x / 2, v.y /2)
    
func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
#        get_tree().reload_current_scene()
        if paused:
            self.paused = false
        else:
            self.paused = true
        
func quit_game():
    get_tree().quit()
    
func start_game():
    $StartScreen.visible = false
    $Game/Skepp.playing = true
    self.paused = false
    
func pause_game(_paused):
    paused = _paused
    get_tree().paused = paused
    $StartScreen.visible = paused
    