extends Node2D
class_name BaseCard

@export var cardData: Dictionary

var spriteSize: Vector2

enum SUIT {
	CLUB,
	DIAMOND,
	HEART,
	SPADE,
}

func _ready() -> void:
	if cardData.has("sprite"):
		$Sprite2D.texture = load(cardData["sprite"])
		spriteSize = $Sprite2D.texture.get_size()
