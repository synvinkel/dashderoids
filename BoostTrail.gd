extends Node

func _on_Skepp_boost(line):
    $Line.points = line
    
func _on_Skepp_boosted():
    $Line.visible = true
    $Anim.play("fade_out")

func _on_Anim_fade_out_finished(anim_name):
    $Line.visible = false
    $Anim.play("idle")
