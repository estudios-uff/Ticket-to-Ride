extends Node

enum State { CHOOSING_OBJECTIVES, PLAYER_TURN, IA_TURN }
var current_state: State


@export var index_player = 0

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


@onready var map = get_node("/root/TutorialTest/Map")
@onready var end_turn_button = $"../EndTurnButton"

var is_game_over: bool = false
var winner_popup_scene = preload("res://src/Scenes/winner_popup.tscn")

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
		ui_instance.player_index = i
		player_uis.append(ui_instance)
		uis_container.add_child(ui_instance)
		ui_instance.visible = (i == 0) # Apenas a UI do primeiro jogador é visível
		
		player_objectives[i] = []	
	for i in range(Global.num_players):
		var player_hand_path_i = map.player_hand_path + "_" + str(i)
		var player_hand_nodepath_i: NodePath = player_hand_path_i
		if player_hand_nodepath_i:
			print(get_node_or_null(player_hand_nodepath_i))
			map.player_hand.append(get_node_or_null(player_hand_nodepath_i))
	
	# Conecta sinal pra checar fim do jogo
	map.route_claimed.connect(_on_map_route_claimed)

func _on_map_route_claimed(player_index):
	if player_index is int and player_index < player_uis.size():
		var routes = map.player_claimed_routes[player_index]
		player_uis[player_index].update_routes_display(routes)
	
	if is_game_over: return # Não faz nada se o jogo já acabou

	# Verifica se o jogador completou todos os seus objetivos
	var all_objectives_completed = true
	if player_objectives.has(player_index) and not player_objectives[player_index].is_empty():
		for objective_texture in player_objectives[player_index]:
			var card_path = objective_texture.resource_path
			if map.objective_card_data.has(card_path):
				var info = map.objective_card_data[card_path]
				if not map.is_objective_complete(player_index, info["from"], info["to"], info["points"]):
					all_objectives_completed = false
					break # Encontrou um objetivo incompleto, pode parar de verificar
	else:
		all_objectives_completed = false # Não tem objetivos, não pode terminar o jogo

	if all_objectives_completed:
		end_game()

# Nova função para finalizar o jogo
func end_game():
	is_game_over = true
	print("FIM DE JOGO! Calculando pontuações...")
	
	var final_scores = {}
	# Calcula para jogadores humanos
	for i in range(Global.num_players):
		final_scores[i] = calculate_player_score(i)
	# Calcula para IAs
	for i in range(len(iaHands)):
		final_scores["ia_" + str(i)] = calculate_player_score("ia_" + str(i))
		
	# Encontra o vencedor
	var winner_id = -1
	var highest_score = -INF
	for id in final_scores:
		var score = final_scores[id]
		print("Pontuação final para Jogador {id}: {score}".format({"id": id, "score": score}))
		if score > highest_score:
			highest_score = score
			winner_id = id
			
	# Desabilita o jogo e mostra o pop-up
	deck_collision_shape.disabled = true
	end_turn_button.disabled = true
	
	show_winner_popup(winner_id, final_scores)

# Adicione esta função
func show_winner_popup(winner_id, final_scores: Dictionary):
	var popup = winner_popup_scene.instantiate()
	add_child(popup) # Adiciona à cena principal
	
	var message = "[center][font_size=24]Fim de Jogo![/font_size][/center]\n\n"
	message += "Pontuações Finais:\n"
	for id in final_scores:
		message += " - Jogador {id}: {final_scores[id]} pontos\n".format({"id": id, "final_scores[id]": final_scores[id]})
		
	message += "\n[b]O vencedor é o Jogador {winner_id} com {final_scores[winner_id]} pontos![/b]".format({"winner_id": winner_id, "final_scores[winner_id]": final_scores[winner_id]})
	
	popup.show_results(message)

func get_route_points(cost: int) -> int:
	match cost:
		1: return 1
		2: return 2
		3: return 4
		4: return 5
		5: return 7
		6: return 8
		7: return 10
		8: return 15
		_: return 0 # Para rotas com custo inválido ou 0

# Calcula a pontuação final de um jogador específico
func calculate_player_score(player_id) -> int:
	var total_score = 0
	
	# 1. Soma os pontos das rotas compradas
	if map.player_claimed_routes.has(player_id):
		for route_dict in map.player_claimed_routes[player_id]:
			total_score += get_route_points(route_dict["cost"])

	# 2. Soma ou subtrai pontos dos objetivos
	if player_objectives.has(player_id):
		for objective_texture in player_objectives[player_id]:
			var card_path = objective_texture.resource_path
			if map.objective_card_data.has(card_path):
				var info = map.objective_card_data[card_path]
				var points = info["points"]
				var from_city = info["from"]
				var to_city = info["to"]
				
				if map.is_objective_complete(player_id, from_city, to_city, points):
					total_score += points # Soma pontos se o objetivo foi completo
				else:
					total_score -= points # SUBTRAI pontos se não foi completo
					
	return total_score
	
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
		
		# Garante que a lista de rotas esteja sempre atualizada no início do turno
		var routes = map.player_claimed_routes[index_player]
		player_uis[index_player].update_routes_display(routes)
		
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
	# Faça com que a IA veja quais os seus objetivos e tente comprar rotas que estejam dentro dos objetivos

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if deck and deck.is_connected("update_player_hand", Callable(self, "_on_deck_card_drawn")):
			deck.update_player_hand.disconnect(_on_deck_card_drawn)
			print("TurnManager desconectado do Deck com segurança.")
