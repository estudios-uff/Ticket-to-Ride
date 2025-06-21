extends Node

enum State { CHOOSING_OBJECTIVES, PLAYER_TURN, IA_TURN }
var current_state: State

var index_player = 0
var playerHands = []
var iaHands = []
var index_ia = 0
var player_uis = []

@onready var uis_container = $"../PlayerUIsContainer"
var player_ui_scene = preload("res://src/Scenes/GUI/components/playerUI.tscn") # Ajuste o caminho do seu projeto

@onready var hands_container = $"../PlayerHandsContainer" 
var player_hand_scene = preload("res://src/Scenes/GUI/components/PlayerHand.tscn")

@onready var deck = get_node("/root/TutorialTest/Deck")
@onready var deck_collision_shape = get_node("/root/TutorialTest/Deck/Area2D/CollisionShape2D")

@onready var manager_objetivos = get_node("/root/TutorialTest/ManagerObjetivos")
var player_objectives = {} 

@onready var end_turn_button = $"../EndTurnButton"

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
		
	if manager_objetivos:
		manager_objetivos.objetivos_escolhidos.connect(_on_objetivos_do_jogador_escolhidos)
		print("TurnManager conectado ao ManagerObjetivos com sucesso!")
	else:
		print("TurnManager ERRO: Nó do ManagerObjetivos não encontrado!")
		
	playerHands.clear()
	iaHands.clear()
	# --- Instancia as mãos da IA ---
	for i in range(5 - Global.num_players):
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "IAHand_" + str(i) # Dá um nome único para debugging
		iaHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = false # Começam escondidas
		player_objectives["ia_" + str(i)] = []
		
	# --- Instancia as mãos dos Jogadores Humanos ---
	for i in range(Global.num_players):
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "PlayerHand_" + str(i) # Nome único
		playerHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		# A mão do primeiro jogador (i == 0) começa visível, as outras não.
		hand_instance.visible = (i == 0)
		
		var ui_instance = player_ui_scene.instantiate()
		ui_instance.name = "PlayerUI_" + str(i)
		player_uis.append(ui_instance)
		uis_container.add_child(ui_instance)
		ui_instance.visible = (i == 0) # Apenas a UI do primeiro jogador é visível
		
		player_objectives[i] = [] 
		
func _on_deck_card_drawn(card_identifier: String) -> void:
	# Verifica se há jogadores humanos no jogo
	if not playerHands.is_empty():
		# Pega a instância da mão do jogador ATIVO
		var active_player_hand = playerHands[index_player]
		
		# Chama a função para adicionar a carta APENAS na mão ativa
		if !active_player_hand.ja_comprou:
			active_player_hand.add_card_to_hand(card_identifier)
			print("Carta '", card_identifier, "' entregue para o Jogador ", index_player + 1)
			active_player_hand.ja_comprou = true
			deck_collision_shape.disabled = true

func _on_end_turn_button_pressed() -> void:
	# Verifica se ainda há um próximo jogador humano no turno
	if index_player + 1 < Global.num_players:
		playerHands[index_player].ja_comprou = false
		deck_collision_shape.disabled = false
		index_player += 1
		change_player_hand()
	else:
		playerHands[index_player].visible = false
		$"../EndTurnButton".disabled = true
		$"../EndTurnButton".visible = false
		
		# Inicia o processo de turno das IAs
		process_ia_turns()

func _on_objetivos_do_jogador_escolhidos(texturas_objetivos: Array[Texture2D]) -> void:
	print("Jogador ", index_player + 1, " escolheu ", texturas_objetivos.size(), " objetivos.")
	player_objectives[index_player] = texturas_objetivos
	
	if index_player < player_uis.size():
		player_uis[index_player].add_objetivos(texturas_objetivos)
	
	current_state = State.PLAYER_TURN
	end_turn_button.disabled = false
	if deck_collision_shape:
		deck_collision_shape.disabled = false
	print("Fase de Objetivos concluída. Iniciando turno normal do jogador.")

func process_ia_turns() -> void:
	# Passa por cada IA
	for i in range(len(iaHands)):
		var current_ia_hand = iaHands[i]
		current_ia_hand.visible = false
		
		print("IA " + str(i) + " está pensando...")
		$"../EnemyThinking".start()
		await $"../EnemyThinking".timeout
		
		opponents_ai_turn(i, current_ia_hand)
		print("IA " + str(i) + " agiu!")
	
	# Todos os turnos da IA acabaram, volta para o primeiro jogador
	print("Turno dos jogadores recomeçando.")
	index_player = 0
	change_player_hand() 
	
	# Reabilita o botão de turno
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true

func change_player_hand() -> void:
	# Esconde todas as mãos
	for hand in playerHands:
		hand.visible = false
	for ui in player_uis:
		ui.visible = false
	
	# Mostra a mão do jogador atual
	if index_player < len(playerHands):
		playerHands[index_player].visible = true
		player_uis[index_player].visible = true
		print("Iniciando turno do Jogador " + str(index_player + 1))
		
		if player_objectives[index_player].is_empty():
			# É o primeiro turno, então mostra a tela de objetivos
			print("Primeira rodada do jogador. Iniciando seleção de objetivos.")
			current_state = State.CHOOSING_OBJECTIVES
			end_turn_button.disabled = true
			if deck_collision_shape:
				deck_collision_shape.disabled = true
			manager_objetivos.iniciar_selecao_de_objetivos()
		else:
			# Não é o primeiro turno, então começa o turno normal
			print("Jogador já possui objetivos. Iniciando turno normal.")
			current_state = State.PLAYER_TURN
			end_turn_button.disabled = false
			if deck_collision_shape:
				deck_collision_shape.disabled = false
				playerHands[index_player].ja_comprou = false

func opponents_ai_turn(ia_index: int, ia_hand_node) -> void:
	print("IA operando com o nó: ", ia_hand_node.name)
	
	if player_objectives["ia_" + str(ia_index)].is_empty():
		print("IA " + str(ia_index) + " está escolhendo seus objetivos iniciais.")
		var objetivos_da_ia = manager_objetivos.get_random_objectives(2)
		player_objectives["ia_" + str(ia_index)] = objetivos_da_ia
		print("IA " + str(ia_index) + " escolheu ", objetivos_da_ia.size(), " objetivos.")
	
	# Resto da lógica da IA (comprar cartas, jogar, etc.)
	print("IA operando com o nó: ", ia_hand_node.name)
	pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if deck and deck.is_connected("update_player_hand", Callable(self, "_on_deck_card_drawn")):
			deck.update_player_hand.disconnect(_on_deck_card_drawn)
			print("TurnManager desconectado do Deck com segurança.")
