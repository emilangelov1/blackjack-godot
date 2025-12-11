extends Node2D

@onready var globalManager: GlobalCardManager = $Background/GlobalCardManager
@onready var player: Player = $Background/Player
@onready var dealer: SingleCardManager = $Background/Dealer
@onready var upsideDownDeck: UpsideDownDeck = $Background/UpsideDownDeck

signal updateScore

var scoreText = preload('res://GameObj/UI/ScoreText/ScoreText.tscn')

var playerScore: ScoreText
var dealerScore: ScoreText


func getPlayerManager() -> SingleCardManager:
	if player.get_child(0):
		return player.get_child(0)
	return


func makeScore(pos: Vector2 = Vector2(480/2, 270/2)) -> Node2D:
	updateScore.connect(onUpdateScore)
	var scoreToUpd = scoreText.instantiate()
	$Background.add_child(scoreToUpd)
	scoreToUpd.visible = false
	scoreToUpd.global_position = pos
	return scoreToUpd


func _ready() -> void:
	playerScore = makeScore(Vector2(480/1.5, 270/2))
	dealerScore = makeScore(Vector2(480/3.5, 270/2))
	$Background/Hit.visible = false
	$Background/Stand.visible = false
	Singleton.hitSignal.connect(onHit)
	Singleton.standSignal.connect(onStand)
	getPlayerManager().deleteCardOnLost.connect(onLostDeleteCard)
	dealer.deleteCardOnLost.connect(onLostDeleteCard)
	globalManager.build()
	initDeal()


func onLostDeleteCard() -> void:
	pass
	
	#TO-DO FIX THIS URGENTLY
	
	#for child in $Background.get_children():
		#if child.is_in_group('toFree'):
			#child.queue_free()


func onUpdateScore(localScore: String, scoreToUpd: ScoreText) -> void:
	if not scoreToUpd: return
	scoreToUpd.visible = true
	
	var scaleTw = create_tween()
	var posTw = create_tween()
	var initPos = scoreToUpd.global_position
	
	scaleTw.parallel()
	posTw.parallel()
	
	scaleTw.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
	posTw.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
	
	scaleTw.tween_property(scoreToUpd, 'scale', Vector2(0.5, 1.5), 0.1)
	posTw.tween_property(scoreToUpd, 'global_position', Vector2(scoreToUpd.global_position.x, scoreToUpd.global_position.y - 10), 0.1)
	
	scoreToUpd.text = localScore
	
	scaleTw.tween_property(scoreToUpd, 'scale', Vector2(1, 1), 0.1)
	posTw.tween_property(scoreToUpd, 'global_position', initPos, 0.1)



func initDeal():
	var shouldHideBtns = false
	var cardFloat = null

	for i in range(2):
		print(i)
		var dealerCard = dealer.addCard(globalManager.drawCard())
		var deleteAfter = (i == 0)
		cardFloat = await upsideDownDeck.animateTo(dealerCard.global_position, deleteAfter)
		if cardFloat:
			upsideDownDeck.cardToFloat = cardFloat
			print(cardFloat)
		if i == 0:
			dealer.revealCard(dealerCard.cardData['name'])
		var playerCard = getPlayerManager().addCard(globalManager.drawCard())
		await upsideDownDeck.animateTo(playerCard.global_position, true)
		await getPlayerManager().revealCard(playerCard.cardData['name'])
		onUpdateScore(str(getPlayerManager().score), playerScore)
		onUpdateScore(str(dealer.score), dealerScore)

	var playerScore = getPlayerManager().score
	var dealerFullScore = dealer.getFullScore()

	if playerScore == 21 or dealerFullScore == 21:
		if cardFloat:
			var flip = Singleton.flip(cardFloat)
			await flip.finished
			cardFloat.queue_free()
		var secondDealerCard = dealer.get_child(1)
		await dealer.revealCard(secondDealerCard.cardData['name'])
		onUpdateScore(str(dealer.score), dealerScore)
		endGame()
		shouldHideBtns = true

	if not shouldHideBtns:
		$Background/Hit.visible = true
		$Background/Stand.visible = true


func onHit():
	var card = getPlayerManager().addCard(globalManager.drawCard())
	await upsideDownDeck.animateTo(card.global_position, true)
	await getPlayerManager().revealCard(card.cardData['name'])
	onUpdateScore(str(getPlayerManager().score), playerScore)
	if getPlayerManager().score > 21:
		dealerTurn()
		return


func onStand():
	dealerTurn()


func flipDealerCard():
	var secondDealerCard = dealer.get_child(1)
	for child in $Background.get_children():
		if child and child.is_in_group('toFree'):
			var flip = await Singleton.flip(child)
			if flip:
				await flip.finished
				child.queue_free()
	await dealer.revealCard(secondDealerCard.cardData['name'])
	onUpdateScore(str(dealer.score), dealerScore)


func dealerTurn():
	$Background/Hit.visible = false
	$Background/Stand.visible = false
	await flipDealerCard()
			#child.queue_free()
	while dealer.score < 17:
		var dealerCard = dealer.addCard(globalManager.drawCard())
		await upsideDownDeck.animateTo(dealerCard.global_position, true)
		await dealer.revealCard(dealerCard.cardData['name'])
		onUpdateScore(str(dealer.score), dealerScore)
	endGame()


func compareHands():
	var playerScore = getPlayerManager().score
	
	if dealer.score > 21 or playerScore > dealer.score and playerScore < 22:
		return "Player Wins!"
	elif playerScore < dealer.score or playerScore > 21:
		return "Dealer Wins!"
	else:
		return "Push"


func endGame():
	var endText: ScoreText = scoreText.instantiate()
	$Background.add_child(endText)
	$Background/Stand.visible = false
	$Background/Hit.visible = false
	playerScore.visible = false
	dealerScore.visible = false
	endText.text = compareHands()
	endText.global_position = Vector2(480 / 2, 270 / 2)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	tween.parallel()
	
	tween.tween_property(endText, 'scale', Vector2(2, 2), 1)
	
	await tween.finished
	
	var tw1 = await dealer.loseAnimation(upsideDownDeck)
	var tw2 = await getPlayerManager().loseAnimation(upsideDownDeck)
	
	await tw1.finished
	await tw2.finished
	
	onRestart()


func onRestart():
	get_tree().reload_current_scene()
