extends Node2D

const CARD_SCENE_PATH = "res://src/Scenes/Cards/card.tscn"

signal update_player_hand(card_drawn)

var player_deck = []

@onready var grayTrain: RichTextLabel = $Gray/RichTextLabel

var trains_deck = {
	"blueTrain": 65,
	"grayTrain": 65,
	"greenTrain": 65,
	"orangeTrain": 65,
	"pinkTrain": 65,
	"redTrain": 65,
	"yellowTrain": 65,
	"rainbowTrain": 95
}

func _ready() -> void:
	player_deck.shuffle()
	
	for key in trains_deck.keys():
		for n in trains_deck[key]:
			player_deck.append(key)
	$RichTextLabel.text = str(player_deck.size())

func draw_card():
	if player_deck.is_empty():
		return # Não faz nada se o baralho estiver vazio

	# Lógica corrigida para comprar e remover a carta
	var card_drawn = player_deck.pick_random()
	player_deck.erase(card_drawn) # Remove a carta específica que foi sorteada
	
	trains_deck[card_drawn] -= 1
	
	# Emite o sinal para o jogador humano
	update_player_hand.emit(card_drawn)
	
	# Atualiza a UI do baralho
	update_deck_visuals()
	
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

func draw_card_for_ia() -> String:
	if player_deck.is_empty():
		return "" # Retorna uma string vazia se o baralho acabou

	# Lógica corrigida para comprar e remover a carta
	var card_drawn = player_deck.pick_random()
	player_deck.erase(card_drawn) # Remove a carta específica
	
	trains_deck[card_drawn] -= 1

	# Atualiza a UI do baralho
	update_deck_visuals()
	
	# Em vez de emitir um sinal, RETORNA o nome da carta
	return card_drawn

# Função auxiliar para não repetir código
func update_deck_visuals():
	$RichTextLabel.text = str(player_deck.size())
	if player_deck.is_empty():
		# Desabilita o baralho visualmente quando ele acaba
		var collision_shape = get_node_or_null("Area2D/CollisionShape2D")
		if collision_shape:
			collision_shape.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
