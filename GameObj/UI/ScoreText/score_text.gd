extends Node2D
class_name ScoreText

var text: String


func _physics_process(delta: float) -> void:
	$Label.text = text
