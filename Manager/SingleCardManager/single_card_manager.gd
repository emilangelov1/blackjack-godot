extends Node2D
class_name SingleCardManager

@export var score = 0

@export var isDealer = true

@export var baseCard: PackedScene

var hand: Array[Dictionary] = []

func _ready() -> void:
	score = 0
	hand.clear()


func dirToGrow(size: Vector2, window: Vector2):
	var totalWidth = hand.size() * size.x
	var startX = (window.x - totalWidth) / 2
	print(size)
	return startX + (hand.size() - 1) * (size.x * 1.5)


func addCard(card: Dictionary) -> Node2D:
	hand.append(card)
	
	var cardScene = baseCard.instantiate()
	
	var marker = Marker2D.new()
	var window = get_viewport_rect().size
	cardScene.cardData = card
	add_child(cardScene)
	cardScene.visible = false
	#print(dirToGrow(cardScene.spriteSize, window))
	if isDealer:
		marker.global_position = Vector2(dirToGrow(cardScene.spriteSize, window),
		(window.y / 2 - cardScene.spriteSize.y)
		)
	else:
		marker.global_position = Vector2(dirToGrow(cardScene.spriteSize, window),
		(window.y / 2) + cardScene.spriteSize.y)
	cardScene.global_position = marker.global_position
	
	updateScore()
	
	return cardScene
	
	if score > 21:
		return


func revealCard(cardName: String):
	for card in get_children():
		var typedCard: BaseCard = card
		var cardSprite: Sprite2D = typedCard.get_node('Sprite2D')
		if typedCard.cardData['name'] == cardName:
			await get_tree().create_timer(Singleton.FLIP_TIMER).timeout
			card.visible = true
			Singleton.flip(typedCard, true)


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
