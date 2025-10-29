extends Node

@onready var sprite = $BackCard

@export var amount = 52

func _ready() -> void:
	for card in amount:
		var genCard = Sprite2D.new()
		genCard.texture = sprite.texture
		var randPosX = sprite.position.x + randf_range(-2.5, 2.5)
		genCard.position = Vector2(randPosX, sprite.position.y - (card / 4))
		add_child(genCard)
