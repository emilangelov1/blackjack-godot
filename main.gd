extends Node2D

@onready var globalManager: GlobalCardManager = $Background/GlobalCardManager
@onready var player: Player = $Background/Player
@onready var dealer: SingleCardManager = $Background/Dealer
@onready var upsideDownDeck: UpsideDownDeck = $Background/UpsideDownDeck


func getPlayerManager() -> SingleCardManager:
	if player.get_child(0):
		return player.get_child(0)
	return


func _ready() -> void:
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


func initDeal():
	for i in range(2):
		print(i)
		var dealerCard = dealer.addCard(globalManager.drawCard())
		var deleteAfter = (i == 0)
		var cardFloat = await upsideDownDeck.animateTo(dealerCard.global_position, deleteAfter)
		if cardFloat:
			upsideDownDeck.cardToFloat = cardFloat
			print(cardFloat)
		if i == 0:
			dealer.revealCard(dealerCard.cardData['name'])
		var playerCard = getPlayerManager().addCard(globalManager.drawCard())
		await upsideDownDeck.animateTo(playerCard.global_position, true)
		await getPlayerManager().revealCard(playerCard.cardData['name'])
		if dealer.score == 21:
			var flip = Singleton.flip(cardFloat)
			await flip.finished
			cardFloat.queue_free()
			if i == 1:
				dealer.revealCard(dealerCard.cardData['name'])
	$Background/Hit.visible = true
	$Background/Stand.visible = true


func onHit():
	var card = getPlayerManager().addCard(globalManager.drawCard())
	await upsideDownDeck.animateTo(card.global_position, true)
	getPlayerManager().revealCard(card.cardData['name'])
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
	dealer.revealCard(secondDealerCard.cardData['name'])


func dealerTurn():
	$Background/Hit.visible = false
	$Background/Stand.visible = false
	flipDealerCard()
			#child.queue_free()
	while dealer.score < 17:
		var dealerCard = dealer.addCard(globalManager.drawCard())
		await upsideDownDeck.animateTo(dealerCard.global_position, true)
		dealer.revealCard(dealerCard.cardData['name'])
	#endGame(compareHands())


func compareHands():
	var playerScore = getPlayerManager().score
	
	if dealer.score > 21 or playerScore > dealer.score:
		return "Player Wins!"
	elif playerScore < dealer.score:
		return "Dealer Wins!"
	else:
		return "Push"


func endGame(msg: String):
	return


func onRestart():
	get_tree().reload_current_scene()
