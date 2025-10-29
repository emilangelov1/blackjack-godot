extends Node2D
class_name BaseCard

const CLUB = 0
const DIAMOND = 1
const HEART = 2
const SPADE = 3

@export_enum("club", "diamond", "heart", "spade") var color
@export var cardNumber: int
@export var sprite: Sprite2D

var SUIT = {
	"club": CLUB,
	"diamond": DIAMOND,
	"heart": HEART,
	"spade": SPADE,
}

func _ready() -> void:
	$Sprite2D.texture = sprite
