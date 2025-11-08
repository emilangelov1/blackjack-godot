extends Node
class_name UpsideDownDeck

@onready var sprite: Sprite2D = $BackCard
@export var amount: int = 52
var isFloating = true
var timePassed = 0

var initPos: Vector2

var cardToFloat: Sprite2D

func _physics_process(delta: float) -> void:
	if isFloating and cardToFloat and is_instance_valid(cardToFloat):
		timePassed += delta
		
		var float_offset = sin(timePassed * 0.3) * 4
		
		cardToFloat.rotation_degrees = sin(timePassed * 0.2) * 2
		
		var scale_variation = 1.0 + sin(timePassed * 0.3) * 0.02
		
		cardToFloat.scale = Vector2(scale_variation, scale_variation)
		
		cardToFloat.skew = sin(timePassed * 0.6) * 0.07


func _ready() -> void:
	#amount = Singleton.globalDeck.size()
	for i in range(amount):
		var genCard := Sprite2D.new()
		genCard.texture = sprite.texture
		genCard.position = Vector2(
			sprite.position.x + randf_range(-5, 5),
			sprite.position.y - 100
		)
		add_child(genCard)
#
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
#
		var finalPos := Vector2(
			genCard.position.x,
			sprite.position.y - (i / 4.0)
		)
#
		var initPos = finalPos
		tween.tween_property(genCard, "position", finalPos, 0.75)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT).set_delay(i * 0.025 + randf() * 0.02)
		#tween.tween_property(genCard, "position", finalPos, 0.05)\
		#.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		
	#animateTo(Vector2(100, 150))
	#shuffleDeck()



func animateTo(position: Vector2, shouldDelete: bool):
	if get_child_count() == 0:
		return
	var cardToAnim = get_child(get_children().size() - 1)
	#var parent = Node2D.new()
	#parent.global_position = cardToAnim.global_position
	var startPos: Vector2 = cardToAnim.global_position
	remove_child(cardToAnim)
	get_parent().add_child(cardToAnim)
	cardToAnim.add_to_group('toFree')
	#get_parent().add_child(parent)
	cardToAnim.global_position = startPos

	cardToAnim.z_index = 5
	var tween := create_tween()
	var window = get_viewport().get_visible_rect().size
	var centerPos = window / 2

	tween.tween_property(cardToAnim, "global_position", centerPos, 0.5)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)\
		.set_delay(0.025 + randf() * 0.02)

	tween.tween_property(cardToAnim, "global_position", position, 0.5)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
		
	await tween.finished
	
	if is_instance_valid(cardToAnim) and shouldDelete:
		var flip = await Singleton.flip(cardToAnim)
		await flip.finished
		cardToAnim.queue_free()
	
	if not shouldDelete:
		return cardToAnim


func delete(id: int):
	get_child(id).parent.queue_free()


func shuffleDeck():
	var window_size = get_viewport().get_visible_rect().size
	var center = window_size / 2
	
	var cards = get_children()

	for i in range(cards.size()):
		var card = cards[i]
		var tween = create_tween()
		var random_offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))

		tween.tween_property(card, "global_position", center + random_offset, 0.45)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)\
			.set_delay(i * 0.006)

	await get_tree().create_timer(0.8).timeout

	for j in range(3):
		for card in cards:
			var tween = create_tween()
			var shake = Vector2(randf_range(-50, 50), randf_range(-15, 15))
			tween.tween_property(card, "global_position", card.global_position + shake, 0.5)\
				.set_trans(Tween.TRANS_CUBIC)
		await get_tree().create_timer(0.5).timeout

	for i in range(cards.size()):
		var card = cards[i]
		var tween = create_tween()
		tween.tween_property(card, "position", Vector2(randf_range(-5, 5), initPos.y - (i / 4.0)), 0.6)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)\
			.set_delay(i * 0.015)
