extends Node

var globalDeck: Array[Dictionary]

signal hitSignal()
signal standSignal()

func hit():
	hitSignal.emit()


func initDeck(deck: Array[Dictionary]):
	deck.shuffle()
	globalDeck = deck


func removeFromDeck(id: int):
	var card_to_remove = null
	for card in globalDeck:
		if card["id"] == id:
			card_to_remove = card
			break
	if card_to_remove:
		var idx = globalDeck.find(card_to_remove)
		globalDeck.remove_at(idx)
	#globalDeck.pop_at(id)


const FLIP_TIMER = 0.25


func flip(card: Node2D, flip: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	
	var originalPos = card.global_position
	var originalScale = card.scale
	var originalRotation = card.rotation_degrees
	var originalModulate = card.modulate
	
	card.scale = Vector2(0, 1) if flip else Vector2(1, 1)
	card.global_position = Vector2(originalPos.x, originalPos.y - 10)
	card.rotation_degrees = originalRotation
	
	tween.tween_property(card, "global_position", originalPos, FLIP_TIMER * 0.6)\
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(card, "scale:x", 1.0 if flip else 0.0, FLIP_TIMER)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	
	tween.tween_property(card, "scale:y", 1.2 if flip else 1.0, FLIP_TIMER * 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(card, "scale:y", 0.9 if flip else 1.05, FLIP_TIMER * 0.2)\
		.set_delay(FLIP_TIMER * 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(card, "scale:y", 1.05 if flip else 0.9, FLIP_TIMER * 0.3)\
		.set_delay(FLIP_TIMER * 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(card, "scale:y", 1.0, FLIP_TIMER * 0.2)\
		.set_delay(FLIP_TIMER * 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
