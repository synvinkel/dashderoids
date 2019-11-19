extends Node2D

var game_started : bool = false
var game_seconds = 0 setget set_game_seconds
var points = 0 setget set_points

signal game_seconds_changed(seconds)
signal points_changed(points)

onready var state setget _set_state

onready var game_timer = $Game/Timer
onready var start_screen = $StartScreen

class GameState:
    func enter(entity):
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class TitleScreen extends GameState:
    func enter(entity):
        print("entering titlescreen")
        var v = entity.get_viewport().size
        for stone in entity.get_tree().get_nodes_in_group("stones"):
        	stone.position = Vector2(v.x / 2, v.y /2)
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class Playing extends GameState:
    func enter(entity):
        entity.connect_to_stones()
        entity.game_seconds = 60
        entity.points = 0
        entity.game_timer.start()
        entity.start_screen.visible = false     
	
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class Paused extends GameState:
    func enter(entity):
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class Won extends GameState:
    func enter(entity):
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass

class Lost extends GameState:
    func enter(entity):
        pass
    func update(entity, delta):
        pass
    func exit(entity):
        pass
		
func _ready():
	self.state = TitleScreen.new()

func pause() -> void:
    if get_tree().paused:
        get_tree().paused = false
        $StartScreen.visible = false
    else:
        get_tree().paused = true
        $StartScreen.visible = true
    
func _process(delta):
	state.update(self, delta)
#    if game_started and Input.is_action_just_pressed("ui_cancel"):
#        pause()
#    if Input.is_action_just_pressed("restart"):
#        get_tree().reload_current_scene()
        
func quit_game():
    get_tree().quit()
    
func start_game():
	self.state = Playing.new()
#    if game_started:
#        pause()   

func set_game_seconds(seconds):
    game_seconds = seconds
    emit_signal("game_seconds_changed", game_seconds)
    if game_seconds <= 0:
        get_tree().reload_current_scene()
        pass

func _on_Timer_timeout():
    self.game_seconds -= 1
    
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
    self.points += int(mass + mass * (game_seconds * game_seconds) * 0.001)
    var stones_alive = 0
    for stone in get_tree().get_nodes_in_group("stones"):
        if stone.alive:
            stones_alive += 1
    if stones_alive == 0:
        print(self.points)
        get_tree().reload_current_scene()

func _set_state(new_state):
    if state != null:
        state.exit(self)
    state = new_state
    new_state.enter(self)

