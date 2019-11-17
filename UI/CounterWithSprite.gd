extends HBoxContainer

export var value = "" setget set_value

func _ready():
    self.value = 200
    pass
    
func set_value(_value):
    value = _value
    $MarginContainer/NinePatchRect/Number.text = str(value)
