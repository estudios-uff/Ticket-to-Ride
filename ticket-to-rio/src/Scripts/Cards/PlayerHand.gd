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

@onready var deck: Node2D # Will be assigned in _ready

var player_hand = {}
var center_screen_x

@onready var ja_comprou = false

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
	
	# Initially hide all labels
	for card_type in player_hand:
		if player_hand[card_type]["label"] is RichTextLabel: # Check if label is valid
			player_hand[card_type]["label"].visible = false
			player_hand[card_type]["label"].text = "0" # Initialize text to 0

	await get_tree().process_frame

	center_screen_x = -get_viewport().size.x / 4

	#var deck_node = get_node_or_null("/root/TutorialTest/Deck") 
	#if deck_node:
		#deck = deck_node
		## Ensure the 'update_player_hand' signal exists in your Deck script and emits a card identifier
		#if deck.has_signal("update_player_hand"):
			#deck.update_player_hand.connect(add_card_to_hand)
			#print("Conectado ao Deck:", deck)
		#else:
			#print("Erro: Sinal 'update_player_hand' não encontrado no Deck.")
	#else:
		#print("Erro: Deck não encontrado!")

func add_card_to_hand(card_identifier: String) -> void:
	if card_identifier in player_hand:
		player_hand[card_identifier]["count"] += 1
		var current_card_data = player_hand[card_identifier]
		var label_node = current_card_data["label"]
		var new_count = current_card_data["count"]

		if label_node is RichTextLabel: # Check if label is valid
			label_node.text = str(new_count)
			label_node.visible = new_count > 0 # Show label if count > 0, hide otherwise
		else:
			print("Erro: Label não é um RichTextLabel para ", card_identifier)
	else:
		print("Carta inválida recebida:", card_identifier)

# Call this function if you implement logic to decrease card counts
func update_card_visibility(card_identifier: String) -> void:
	if card_identifier in player_hand:
		var current_card_data = player_hand[card_identifier]
		var label_node = current_card_data["label"]
		var current_count = current_card_data["count"]

		if label_node is RichTextLabel:
			label_node.text = str(current_count) # Update text even if it becomes 0
			label_node.visible = current_count > 0
		else:
			print("Erro: Label não é um RichTextLabel para ", card_identifier, " em update_card_visibility")
	else:
		print("Carta inválida em update_card_visibility:", card_identifier)



func calculate_card_position(idx):
	var total_width = player_hand.size() - 1 * CARD_WIDTH
	@warning_ignore("integer_division")
	var x_offset = int(center_screen_x + idx * CARD_WIDTH - total_width / 2)
	return x_offset

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)


# If you implement card removal, ensure you update visibility
func remove_card_from_hand(card_identifier: String) -> void:
	if card_identifier in player_hand:
		if player_hand[card_identifier]["count"] > 0:
			player_hand[card_identifier]["count"] -= 1
			update_card_visibility(card_identifier) # Update text and visibility
			# If you were physically removing card nodes, that logic would go here.
			# For now, this just decrements the count.
		else:
			print("Tentativa de remover carta com contagem zero:", card_identifier)
		# If you were actually removing card objects from a list:
		# player_hand.erase(card_identifier) # This would remove the key entirely
		# update_hand_position() 
	else:
		print("Tentativa de remover carta inválida:", card_identifier)
