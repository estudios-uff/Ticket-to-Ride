extends Node

var index_player = 0
var playerHands = []
var iaHands = []
var index_ia = 0

@onready var hands_container = $"../PlayerHandsContainer" 
var player_hand_scene = preload("res://src/Scenes/GUI/components/PlayerHand.tscn")

@onready var deck = get_node("/root/TutorialTest/Deck")

func _ready() -> void:
	# Conecta o sinal do Deck a uma função AQUI no TurnManager
	if deck:
		if deck.has_signal("update_player_hand"):
			# Quando o deck emitir o sinal, a função _on_deck_card_drawn será chamada
			deck.update_player_hand.connect(_on_deck_card_drawn)
			print("TurnManager conectado ao Deck com sucesso!")
		else:
			print("TurnManager ERRO: Sinal 'update_player_hand' não encontrado no Deck.")
	else:
		print("TurnManager ERRO: Nó do Deck não encontrado!")
	playerHands.clear()
	iaHands.clear()
	# --- Instancia as mãos da IA ---
	for i in range(5 - Global.num_players):
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "IAHand_" + str(i) # Dá um nome único para debugging
		iaHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = false # Começam escondidas

	# --- Instancia as mãos dos Jogadores Humanos ---
	for i in range(Global.num_players):
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "PlayerHand_" + str(i) # Nome único
		playerHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		# A mão do primeiro jogador (i == 0) começa visível, as outras não.
		hand_instance.visible = (i == 0)
		
func _on_deck_card_drawn(card_identifier: String) -> void:
	# Verifica se há jogadores humanos no jogo
	if not playerHands.is_empty():
		# Pega a instância da mão do jogador ATIVO
		var active_player_hand = playerHands[index_player]
		
		# Chama a função para adicionar a carta APENAS na mão ativa
		active_player_hand.add_card_to_hand(card_identifier)
		print("Carta '", card_identifier, "' entregue para o Jogador ", index_player + 1)

func _on_end_turn_button_pressed() -> void:
	# Verifica se ainda há um próximo jogador humano no turno
	if index_player + 1 < Global.num_players:
		index_player += 1
		change_player_hand()
	else:
		playerHands[index_player].visible = false
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		
		# Inicia o processo de turno das IAs
		process_ia_turns()


func process_ia_turns() -> void:
	# Passa por cada IA
	for i in range(len(iaHands)):
		var current_ia_hand = iaHands[i]
		current_ia_hand.visible = false
		
		print("IA " + str(i) + " está pensando...")
		$"../EnemyThinking".start()
		await $"../EnemyThinking".timeout
		
		opponents_ai_turn(current_ia_hand)
		print("IA " + str(i) + " agiu!")
	
	# Todos os turnos da IA acabaram, volta para o primeiro jogador
	print("Turno dos jogadores recomeçando.")
	index_player = 0
	change_player_hand() 
	
	# Reabilita o botão de turno
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true

func change_player_hand() -> void:
	# Esconde todas as mãos de jogadores humanos
	for hand in playerHands:
		hand.visible = false
	# Mostra apenas a mão do jogador atual
	if index_player < len(playerHands):
		playerHands[index_player].visible = true
		print("Agora é o turno do Jogador " + str(index_player + 1))

func opponents_ai_turn(ia_hand_node) -> void:
	# Implementar compra de cartas e tomada de decisão da IA aqui
	print("IA operando com o nó: ", ia_hand_node.name)
	pass
