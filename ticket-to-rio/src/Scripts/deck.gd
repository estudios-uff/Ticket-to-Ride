extends Node2D

const CARD_SCENE_PATH = "res://src/Scenes/Cards/card.tscn"

var player_deck = ["A","A","A","A","A"]


func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	# ADICIONA UMA POR VEZ ATE ACABAR O DECK
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
	
	# ADICIONA VARIAS CARTAS NA MAO DE UMA VEZ
	#for i in range(player_deck.size()):
		#var new_card = card_scene.instantiate()
		#$"../CardManager".add_child(new_card)
		#new_card.name = "Card"
		#$"../PlayerHand".add_card_to_hand(new_card)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = str(player_deck.size())



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
