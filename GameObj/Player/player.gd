extends Node2D
class_name Player

@export var cardManager: PackedScene


func _ready() -> void:
	if(cardManager):
		var manager: SingleCardManager = cardManager.instantiate()
		add_child(manager)
		manager.isDealer = false
