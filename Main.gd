extends Node2D

var game_started : bool = false
var game_timer = 0 setget set_game_timer
var points = 0 setget set_points

signal game_time_changed(time)
signal points_changed(points)

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
        connect_to_stones()
        self.game_timer = 60
        self.points = 0
        $Game/Timer.start()
        $StartScreen.visible = false        

func set_game_timer(time):
    game_timer = time
    emit_signal("game_time_changed", game_timer)
    if game_timer <= 0:
        get_tree().reload_current_scene()
        pass

func _on_Timer_timeout():
    self.game_timer -= 1
    
func set_points(_points):
    points = _points
    emit_signal("points_changed", points)
    
func connect_to_stones() -> void:
    for stone in get_tree().get_nodes_in_group("stones"):
        stone.connect("stone_split", self, "_on_stone_split")
        stone.connect("stone_broke", self, "_on_stone_broke")
        
func _on_stone_split():
    connect_to_stones()
    
func _on_stone_broke(mass):
    self.points += int(mass + mass * (game_timer * game_timer) * 0.001)
    var stones_alive = 0
    for stone in get_tree().get_nodes_in_group("stones"):
        if stone.alive:
            stones_alive += 1
    if stones_alive == 0:
        print(self.points)
        get_tree().reload_current_scene()

