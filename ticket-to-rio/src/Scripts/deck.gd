extends Node2D

const CARD_SCENE_PATH = "res://src/Scenes/Cards/card.tscn"

signal update_player_hand(card_drawn)

var player_deck = []

@onready var grayTrain: RichTextLabel = $Gray/RichTextLabel

var trains_deck = {
	"blueTrain": 20,
	"grayTrain": 20,
	"greenTrain": 20,
	"orangeTrain": 20,
	"pinkTrain": 20,
	"redTrain": 20,
	"yellowTrain": 20,
	"rainbowTrain": 24
}

func _ready() -> void:
	player_deck.shuffle()
	
	for key in trains_deck.keys():
		for n in trains_deck[key]:
			player_deck.append(key)
	$RichTextLabel.text = str(player_deck.size())

func draw_card():
	#var card_drawn = player_deck[0]
	var card_drawn = player_deck.pick_random()

	player_deck.pop_back()
	
	trains_deck[card_drawn] -= 1
	update_player_hand.emit(card_drawn)
	
	#if $"../PlayerHand".player_hand.size() <= 7:	
		#player_deck.erase(card_drawn)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	# ADICIONA UMA POR VEZ ATE ACABAR O DECK
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://images/cards/" + card_drawn + ".png")
	new_card.get_node("BackCardImage").texture = load(card_image_path)
	
	#if $"../PlayerHand".player_hand.size() <= 4:
		#$"../CardManager".add_child(new_card)
		#new_card.name = "Card"
		#$"../PlayerHand".add_card_to_hand(new_card)
	
	# ADICIONA VARIAS CARTAS NA MAO DE UMA VEZ
	#for i in range(player_deck.size()):
		#var new_card = card_scene.instantiate()
		#$"../CardManager".add_child(new_card)
		#new_card.name = "Card"
		#$"../PlayerHand".add_card_to_hand(new_card)
