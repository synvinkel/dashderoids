extends Control

onready var TimeCounter = $TOP/HBoxContainer/TimeCounter
onready var PointsCounter = $TOP/HBoxContainer/PointsCounter

func _ready():
    print(TimeCounter)

func _on_Main_game_seconds_changed(time):
    var minutes = str(floor(time / 60))
    var seconds = str(time % 60)
    if minutes.length() < 2:
        minutes = "0" + minutes
    if seconds.length() < 2:
        seconds = "0" + seconds
    TimeCounter.value = minutes + ":" + seconds


func _on_Main_points_changed(points):
    PointsCounter.value = str(points)
