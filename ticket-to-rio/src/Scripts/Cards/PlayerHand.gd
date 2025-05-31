extends Node2D

#const HAND_COUNT = 4
#const CARD_SCENE_PATH = "res://src/Scenes/Cards/card.tscn"
const CARD_WIDTH = 100
const HAND_Y_POSITION = 260

@onready var blue: RichTextLabel = $Blue/RichTextLabel
@onready var pink: RichTextLabel = $Pink/RichTextLabel
@onready var yellow: RichTextLabel = $Yellow/RichTextLabel
@onready var red: RichTextLabel = $Red/RichTextLabel
@onready var orange: RichTextLabel = $Orange/RichTextLabel
@onready var gray: RichTextLabel = $Gray/RichTextLabel
@onready var green: RichTextLabel = $Green/RichTextLabel
@onready var rainbow: RichTextLabel = $Rainbow/RichTextLabel

@onready var deck: Node2D = $Deck

var player_hand = {}

var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	player_hand = {
		"blueTrain": {"count": 0, "label": blue},
		"grayTrain": {"count": 0, "label": gray},
		"greenTrain": {"count": 0, "label": green},
		"orangeTrain": {"count": 0, "label": orange},
		"pinkTrain": {"count": 0, "label": pink},
		"redTrain": {"count": 0, "label": red},
		"yellowTrain": {"count": 0, "label": yellow},
		"rainbowTrain": {"count": 0, "label": rainbow}
	}
	
	await get_tree().process_frame

	center_screen_x = -get_viewport().size.x / 4

	# Tenta encontrar o Deck no caminho correto.
	var deck_node = get_node_or_null("../Deck")  # Ajuste conforme a hierarquia

	if deck_node:
		deck = deck_node
		deck.update_player_hand.connect(add_card_to_hand)
		print("Conectado ao Deck:", deck)
	else:
		print("Erro: Deck não encontrado!")

func add_card_to_hand(card):
	player_hand[card]["count"] += 1
	if card in player_hand:
		var new_count = player_hand[card]["count"]
		player_hand[card]["label"].text = str(new_count)
	else:
		print("Carta inválida:", card)

func calculate_card_position(idx):
	var total_width = player_hand.size() - 1 * CARD_WIDTH
	@warning_ignore("integer_division")
	var x_offset = int(center_screen_x + idx * CARD_WIDTH - total_width / 2)
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
