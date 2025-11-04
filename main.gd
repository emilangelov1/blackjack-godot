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
	Singleton.hitSignal.connect(onHit)
	Singleton.standSignal.connect(onStand)
	globalManager.build()
	initDeal()


func initDeal():
	for i in range(2):
		print(i)
		var dealerCard = dealer.addCard(globalManager.drawCard())
		var deleteAfter = (i == 0)
		await upsideDownDeck.animateTo(dealerCard.global_position, deleteAfter)
		if i == 0:
			dealer.revealCard(dealerCard.cardData['name'])
		var playerCard = getPlayerManager().addCard(globalManager.drawCard())
		await upsideDownDeck.animateTo(playerCard.global_position, true)
		getPlayerManager().revealCard(playerCard.cardData['name'])


func onHit():
	print('VLAGA')
	var card = getPlayerManager().addCard(globalManager.drawCard())
	await upsideDownDeck.animateTo(card.global_position, true)
	getPlayerManager().revealCard(card.cardData['name'])
	if getPlayerManager().score > 21:
		endGame("Dealer Wins!")

func onStand():
	dealerTurn()


func dealerTurn():
	while dealer.score < 17:
		dealer.addCard(globalManager.drawCard())
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
