extends Node

enum State { CHOOSING_OBJECTIVES, PLAYER_TURN, IA_TURN }
var current_state: State


@export var index_player = 0

var playerHands = []
var iaHands = []
var index_ia = 0
var player_uis = []

@onready var uis_container = $"../PlayerUIsContainer"
var player_ui_scene = preload("res://src/Scenes/GUI/components/playerUI.tscn")

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
var round_idx = 1

func _ready() -> void:
	# --- PASSO 1 (O MAIS IMPORTANTE): Atribuir as cores PRIMEIRO ---
	# Isso garante que o dicionário Global.participants esteja pronto para ser usado.
	Global.assign_participant_colors(Global.num_players, 5 - Global.num_players)

	# --- PASSO 2: Conectar todos os sinais ---
	if deck and deck.has_signal("update_player_hand"):
		deck.update_player_hand.connect(_on_deck_card_drawn)
	if manager_objetivos and manager_objetivos.has_signal("objetivos_escolhidos"):
		manager_objetivos.objetivos_escolhidos.connect(_on_objetivos_do_jogador_escolhidos)
	map.route_claimed.connect(_on_map_route_claimed)
	
	# --- PASSO 3: Limpar todos os arrays de estado ---
	playerHands.clear()
	iaHands.clear()
	player_uis.clear()
	player_objectives.clear()
	map.player_hand.clear()
	
	# --- PASSO 4: Instanciar as IAs ---
	for i in range(5 - Global.num_players):
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "IAHand_" + str(i)
		iaHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = false
		player_objectives["ia_" + str(i)] = []
		
	# --- PASSO 5: Instanciar os Jogadores Humanos (Mãos e UIs) ---
	# Este é o ÚNICO laço necessário para os jogadores humanos.
	for i in range(Global.num_players):
		# 5a. Instancia a Mão
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "PlayerHand_" + str(i)
		playerHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = (i == 0)
		
		# 5b. Adiciona a referência da mão ao Mapa (O JEITO CERTO)
		# Em vez de procurar por texto, passamos a referência direta. 100% garantido.
		map.player_hand.append(hand_instance)

		# 5c. Instancia a UI
		var ui_instance = player_ui_scene.instantiate()
		ui_instance.name = "PlayerUI_" + str(i)
		ui_instance.player_index = i
		
		# 5d. Pega os dados do Global e configura a UI
		var p_color = Global.get_participant_color(i)
		var p_name = Global.get_participant_display_name(i)
		ui_instance.set_player_info(p_color, p_name)
		
		player_uis.append(ui_instance)
		uis_container.add_child(ui_instance)
		ui_instance.visible = (i == 0)
		player_objectives[i] = []
	
func _on_map_route_claimed(player_index):
	print("TurnManager: Rota comprada recebida do jogador/IA: " + str(player_index))

	# Parte 1: Atualização da Interface (só para jogadores humanos)
	if player_index is int:
		# Verifica se o índice é válido para a lista de UIs de jogadores
		if player_index < player_uis.size():
			var routes = map.player_claimed_routes[player_index]
			player_uis[player_index].update_routes_display(routes)

	# Parte 2: Lógica de Fim de Jogo (executa para TODOS, humanos e IAs)
	if is_game_over:
		return # Não faz mais verificações se o jogo já terminou

	var all_objectives_completed = true
	
	# A verificação a seguir funciona com 'player_index' sendo int ou string
	if player_objectives.has(player_index) and not player_objectives[player_index].is_empty():
		for objective_texture in player_objectives[player_index]:
			var card_path = objective_texture.resource_path
			if map.objective_card_data.has(card_path):
				var info = map.objective_card_data[card_path]
				
				if player_index is int:
					if not map.is_objective_complete(player_index, info["from"], info["to"], info["points"]):
						all_objectives_completed = false
						break # Encontrou um objetivo incompleto, pode parar de verificar
				else:
					if map.find_shortest_path_routes(info["from"], info["to"]):
						all_objectives_completed = false
						break # Encontrou um objetivo incompleto, pode parar de verificar
			else:
				# Se a carta não está no dicionário de dados, consideramos incompleto
				all_objectives_completed = false
				break
	else:
		# Não tem objetivos ou a lista está vazia, não pode terminar o jogo
		all_objectives_completed = false

	# Se, após a verificação, todos os objetivos estiverem completos...
	if all_objectives_completed:
		print("CONDIÇÃO DE FIM DE JOGO ATINGIDA PELO JOGADOR/IA: " + player_index)
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
				
				if player_id is int:
					if map.is_objective_complete(player_id, from_city, to_city, points):
						total_score += points # Soma pontos se o objetivo foi completo
					else:
						total_score -= points # SUBTRAI pontos se não foi completo
				else:
					if map.find_shortest_path_routes(from_city, to_city):
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
			$"../EndTurnButton".disabled = false


func _on_end_turn_button_pressed() -> void:
	if not playerHands[index_player].ja_comprou:
		return
	
	# Verifica se ainda há um próximo jogador humano no turno
	if index_player + 1 < Global.num_players:
		playerHands[index_player].ja_comprou = false
		deck_collision_shape.disabled = false
		index_player += 1
		change_player_hand()
	else:
		playerHands[index_player].visible = false
		player_uis[index_player].visible = false
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
	round_idx += 1
	index_player = 0
	change_player_hand() 
	
	# Reabilita o botão de turno
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
			if deck_collision_shape:
				deck_collision_shape.disabled = false
				playerHands[index_player].ja_comprou = false

func _ai_can_afford_route(hand_node, route_data: Dictionary) -> bool:
	var cost = route_data.cost
	var color_str = route_data.color
	var card_key = map.color_name_to_card_key(color_str)
	var rainbow_count = hand_node.player_hand["rainbowTrain"]["count"]

	if card_key == "grayTrain":
		# Para rotas cinzas, a IA precisa de qualquer cor ou coringas
		var max_cards_of_one_color = 0
		for key in hand_node.player_hand:
			if key != "rainbowTrain":
				max_cards_of_one_color = max(max_cards_of_one_color, hand_node.player_hand[key]["count"])
		return max_cards_of_one_color + rainbow_count >= cost
	else:
		# Para rotas coloridas, verifica a cor específica + coringas
		var color_count = hand_node.player_hand[card_key]["count"]
		return color_count + rainbow_count >= cost

func _ai_pay_for_route(hand_node, route_data: Dictionary):
	var cost = route_data.cost
	var color_str = route_data.color
	var card_key = map.color_name_to_card_key(color_str)
	var rainbow_count = hand_node.player_hand["rainbowTrain"]["count"]
	
	if card_key == "grayTrain":
		var best_color = ""
		var best_count = 0
		for key in hand_node.player_hand.keys():
			if key != "rainbowTrain":
				if hand_node.player_hand[key]["count"] > best_count:
					best_count = hand_node.player_hand[key]["count"]
					best_color = key
		var use_from_color = min(cost, best_count)
		for i in range(use_from_color): hand_node.remove_card_from_hand(best_color)
		for i in range(cost - use_from_color): hand_node.remove_card_from_hand("rainbowTrain")
	else:
		var color_count = hand_node.player_hand[card_key]["count"]
		var use_from_color = min(cost, color_count)
		for i in range(use_from_color): hand_node.remove_card_from_hand(card_key)
		for i in range(cost - use_from_color): hand_node.remove_card_from_hand("rainbowTrain")

func opponents_ai_turn(ia_index: int, ia_hand_node) -> void:
	var ia_id = "ia_" + str(ia_index)
	print("--- INÍCIO TURNO: IA " + str(ia_index) + " ---")

	# 1. Lógica de escolher objetivos (só na primeira rodada)
	if player_objectives[ia_id].is_empty():
		print("IA " + str(ia_index) + " está escolhendo seus objetivos iniciais.")
		var objetivos_da_ia = manager_objetivos.get_random_objectives(2)
		player_objectives[ia_id] = objetivos_da_ia
		print("IA " + str(ia_index) + " escolheu {objetivos_da_ia.size()} objetivos.".format({"objetivos_da_ia.size()": objetivos_da_ia.size()}))

	# 2. A IA sempre compra uma carta no início do turno
	if deck.has_method("draw_card_for_ia"): # Garante que a função existe no Deck
		var drawn_card = deck.draw_card_for_ia()
		if drawn_card:
			ia_hand_node.add_card_to_hand(drawn_card)
			print("IA " + str(ia_index) + " comprou a carta: {drawn_card}".format({"drawn_card": drawn_card}))
	
	# 3. Criar uma "lista de desejos" de rotas para completar objetivos
	var wishlist: Array = []
	for objective_texture in player_objectives[ia_id]:
		var card_path = objective_texture.resource_path
		if map.objective_card_data.has(card_path):
			var info = map.objective_card_data[card_path]
			# Se o objetivo ainda não foi completo...
			if map.find_shortest_path_routes(info.from, info.to):
				var routes_for_objective = map.find_shortest_path_routes(info.from, info.to)
				for r in routes_for_objective:
					if not r in wishlist: # Evita duplicatas
						wishlist.append(r)
	
	print("IA " + str(ia_index) + " tem {wishlist.size()} rotas na sua lista de desejos.".format({"wishlist.size()": wishlist.size()}))

	# 4. Tentar comprar a primeira rota possível da lista de desejos
	for route_data in wishlist:
		# Encontra o nó da rota na cena para verificar se já foi comprada
		var route_node = map.get_route_node_by_data(route_data) # Precisamos criar esta função
		if route_node and not route_node.claimed:
			# Verifica se tem cartas suficientes
			if _ai_can_afford_route(ia_hand_node, route_data):
				print("IA " + str(ia_index) + " PODE e VAI comprar a rota de {route_data.from} para {route_data.to}".format({"route_data.from": route_data.from, "route_data.to": route_data.to}))
				
				# Paga pelas cartas e manda o mapa registrar a compra
				_ai_pay_for_route(ia_hand_node, route_data)
				map.claim_route_for_player(route_node, ia_id)
				
				print("--- FIM TURNO: IA " + str(ia_index) + " (comprou uma rota) ---")
				map.get_child(2).text = map.get_child(2).text + "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (comprou uma rota)\n"
				return # Termina o turno após uma ação bem-sucedida

	print("--- FIM TURNO: IA " + str(ia_index) + " (não comprou nada) ---")
	map.get_child(2).text = map.get_child(2).text + "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (não comprou uma rota)\n"

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if deck and deck.is_connected("update_player_hand", Callable(self, "_on_deck_card_drawn")):
			deck.update_player_hand.disconnect(_on_deck_card_drawn)
			print("TurnManager desconectado do Deck com segurança.")
