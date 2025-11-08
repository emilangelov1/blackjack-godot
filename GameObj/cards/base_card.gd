extends Node2D
class_name BaseCard

@export var cardData: Dictionary

var spriteSize: Vector2
var timePassed: float = 0.0
var isFloating: bool = true
var originalPos: Vector2

enum SUIT {
	CLUB,
	DIAMOND,
	HEART,
	SPADE,
}

enum FACES {
	JACK,
	QUEEN,
	KING
}

func _ready() -> void:
	if cardData.has("sprite"):
		$Sprite2D.texture = load(cardData["sprite"])
		spriteSize = $Sprite2D.texture.get_size()
	
	originalPos = position

func _physics_process(delta: float) -> void:
	if isFloating:
		timePassed += delta
		
		var float_offset = sin(timePassed * 0.3) * 4
		#position.y = originalPos.y + float_offset
		
		rotation_degrees = sin(timePassed * 0.2) * 2
		
		var scale_variation = 1.0 + sin(timePassed * 0.3) * 0.02
		scale = Vector2(scale_variation, scale_variation)
		
		skew = sin(timePassed * 0.6) * 0.07
