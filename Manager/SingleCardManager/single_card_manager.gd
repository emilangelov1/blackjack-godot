extends Node2D
class_name SingleCardManager

@export var score = 0
@export var isDealer = true
@export var baseCard: PackedScene

signal deleteCardOnLost

var hand: Array[Dictionary] = []
var cardSpacing: float = 1.1
var cardWidth: float = 0.0

@onready var scoreText = load('res://GameObj/UI/ScoreText/ScoreText.tscn')

func _ready() -> void:
	score = 0
	hand.clear()
	get_parent().add_child(scoreText)
	if scoreText:
		scoreText.text = str(score)


func _physics_process(delta: float) -> void:
	if scoreText:
		scoreText.text = str(score)


func getCardPosition(index: int, cardSize: Vector2, window: Vector2) -> Vector2:
	var totalWidth = hand.size() * cardSize.x * (cardSpacing - (hand.size() * 0.02))
	var startX = (window.x - totalWidth) / 2
	print(cardSpacing - (hand.size() * 0.05))
	var xPos = startX + index * (cardSize.x * cardSpacing)
	
	if isDealer:
		return Vector2(xPos, window.y / 2 - cardSize.y)
	else:
		return Vector2(xPos, window.y / 2 + cardSize.y)

func updateCardPositions():
	var window = get_viewport_rect().size
	var children = get_children()
	
	for i in range(children.size()):
		var card = children[i]
		if card is BaseCard:
			var targetPosition = getCardPosition(i, card.spriteSize, window)
			
			if card.visible:
				var tween = create_tween()
				tween.set_parallel(true)
				tween.tween_property(card, "global_position", targetPosition, 0.3)\
					.set_ease(Tween.EASE_IN_OUT)
				
				tween.tween_property(card, "scale", Vector2(1.05, 1.05), 0.15)\
					.set_ease(Tween.EASE_OUT)
				tween.tween_property(card, "scale", Vector2(1, 1), 0.15)\
					.set_delay(0.15).set_ease(Tween.EASE_IN)
			else:
				card.global_position = targetPosition

func addCard(card: Dictionary) -> Node2D:
	hand.append(card)
	
	var cardScene = baseCard.instantiate()
	cardScene.cardData = card
	add_child(cardScene)
	cardScene.visible = false
	
	if cardWidth == 0 and cardScene.has_method("get_sprite_size"):
		cardWidth = cardScene.spriteSize.x
	
	var window = get_viewport_rect().size
	
	cardScene.global_position = Vector2(window.x + 100, 
		getCardPosition(0, cardScene.spriteSize, window).y)
	
	updateCardPositions()
	
	var targetPosition = getCardPosition(hand.size() - 1, cardScene.spriteSize, window)
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(cardScene, "global_position", targetPosition, 0.5)\
		.set_ease(Tween.EASE_IN_OUT)
	
	cardScene.scale = Vector2(0.8, 0.8)
	cardScene.rotation_degrees = 10
	tween.tween_property(cardScene, "scale", Vector2(1, 1), 0.5)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(cardScene, "rotation_degrees", 0, 0.5)\
		.set_ease(Tween.EASE_IN_OUT)
	
	var liftPosition = targetPosition - Vector2(0, 20)
	tween.tween_property(cardScene, "global_position", liftPosition, 0.25)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(cardScene, "global_position", targetPosition, 0.25)\
		.set_delay(0.25).set_ease(Tween.EASE_IN)
	
	updateScore()
	
	return cardScene


func revealCard(cardName: String):
	for card in get_children():
		var typedCard: BaseCard = card
		var cardSprite: Sprite2D = typedCard.get_node('Sprite2D')
		if typedCard.cardData['name'] == cardName:
			await get_tree().create_timer(Singleton.FLIP_TIMER).timeout
			card.visible = true
			var flip = Singleton.flip(typedCard, true)
			await flip.finished


func updateScore() -> void:
	score = 0
	var aces = 0
	if isDealer and score == 17:
		return
	for card in hand:
		var cardVal = card['value']
		if cardVal == 1:
			aces += 1
			score += 11
		else:
			score += cardVal
	while score > 21 and aces > 0:
		score -= 10
		aces -= 1


func resetHand() -> void:
	for c in get_children():
		if c is BaseCard:
			c.queue_free()
	hand.clear()
	score = 0


#func loseAnimation() -> void:
	#const ANIM_TIME = 7
	#var cards = get_children()
	#for card in cards:
		#var tween = create_tween()
		#
		#tween.set_parallel(true)
		#
		#tween.tween_property(card, 'global_position', 
		#Vector2(card.global_position.x, card.global_position.y - 300), ANIM_TIME / 2)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'global_position:x', 
		#card.global_position.x - 20, ANIM_TIME / 4)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'scale', 
		#Vector2(card.scale.x - 0.5, card.scale.y + 0.5), ANIM_TIME / 2)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'global_position:x', 
		#card.global_position.x + 20, ANIM_TIME / 4)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'global_position', 
		#Vector2(card.global_position.x, card.global_position.y + 100), ANIM_TIME / 2)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'global_position:x', 
		#card.global_position.x - 20, ANIM_TIME / 4)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#
		#tween.tween_property(card, 'scale', 
		#Vector2(card.scale.x + 0.5, card.scale.y - 0.5), ANIM_TIME / 2)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'global_position:x', 
		#card.global_position.x + 20, ANIM_TIME / 4)\
		#.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'scale', 
		#Vector2(0, 0), ANIM_TIME / 2)\
		#.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		#
		#tween.tween_property(card, 'modulate', 
		#Color(1, 1, 1, 0), ANIM_TIME / 3)\
		#.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)


func loseAnimation(deck: UpsideDownDeck) -> void:
	var idx = 0
	for card in get_children():
		var flip = Singleton.flip(card, true)
		await flip.finished
		var flippedCard = Sprite2D.new()
		flippedCard.texture = load('res://GameObj/sprites/cardBack/backCard.png')
		add_child(flippedCard)
		flippedCard.global_position = card.global_position
		
		var tween = create_tween()
		
		tween.tween_property(flippedCard, 'global_position',
		Vector2(randf_range(deck.global_position.x - 0.5, deck.global_position.x + 0.5),
		randf_range(deck.global_position.y - 0.5, deck.global_position.y + 0.5)), 0.5)\
		.set_delay(idx * 0.15).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
		
		idx += 1
		
		card.queue_free()
	
	deleteCardOnLost.emit()
