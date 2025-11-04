extends Node2D
class_name GlobalCardManager

var cards: PackedStringArray

var idx = 0

var deck: Array[Dictionary]

var SUIT = BaseCard.SUIT

func getCardValue(cardName: String):
	var num := ""
	#var hasNum := false
	for letter in cardName:
		if letter in "0123456789":
			#print(letter)
			num += letter
			#hasNum = true
			#break
	for face in SUIT:
		if cardName.containsn(face):
			num = "10"
	return int(num)

func build() -> void:
	cards = DirAccess.open('res://GameObj/sprites/cards/').get_files()
	
	#print(cards)
	for card in cards:
		if card.contains('.png.import'): continue
		var cardAppend = card.find('.')
		var cardName = card.substr(0, cardAppend)
		getCardValue(cardName)
		var buildDeck = {
			"name": cardName,
			"id": idx,
			"value": getCardValue(cardName),
			"sprite": "res://GameObj/sprites/cards/%s.png" % cardName
		}
		#print(buildDeck)
		idx += 1
		deck.push_back(buildDeck)
	Singleton.initDeck(deck)
	#Singleton.removeFromDeck(deck.pick_random()['id'])


func drawCard() -> Dictionary:
	if deck.is_empty():
		build()
		deck.shuffle()
	return deck.pop_back()
