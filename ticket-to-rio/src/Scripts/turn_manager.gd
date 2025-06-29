extends Node

enum State { CHOOSING_OBJECTIVES, PLAYER_TURN, IA_TURN, DRAWING_CARDS }
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

@onready var loja_cards = get_node("/root/TutorialTest/NodeLoja/GroupShopTicket")
var cards_drawn_this_turn: int = 0
var selected_shop_cards: Array[Control] = [] # Para guardar os NÓS das cartas selecionadas

@onready var map = get_node("/root/TutorialTest/Map")
@onready var end_turn_button = $"../EndTurnButton"

var is_game_over: bool = false
var winner_popup_scene = preload("res://src/Scenes/winner_popup.tscn")
var round_idx = 1

func _ready() -> void:
	# --- PASSO 1: Atribuir as cores aos jogadores ---
	Global.assign_participant_colors(Global.num_players, 5 - Global.num_players)

	# --- PASSO 2: Conectar todos os sinais ---
	if deck and deck.has_signal("update_player_hand"):
		deck.update_player_hand.connect(_on_deck_card_drawn)
	if manager_objetivos and manager_objetivos.has_signal("objetivos_escolhidos"):
		manager_objetivos.objetivos_escolhidos.connect(_on_objetivos_do_jogador_escolhidos)
	if map:
		map.route_claimed.connect(_on_map_route_claimed)
		map.all_routes_completed.connect(end_game)
	if loja_cards:
		loja_cards.draw_button_pressed.connect(_on_shop_draw_button_pressed)
	
	# --- PASSO 3: Limpar todos os arrays de estado ---
	playerHands.clear()
	iaHands.clear()
	player_uis.clear()
	player_objectives.clear()
	map.player_hand.clear()
	
	# --- PASSO 4: Instanciar os Jogadores Humanos (Mãos e UIs) ---
	for i in range(Global.num_players):
		# 4a. Instancia a Mão
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "PlayerHand_" + str(i)
		playerHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = (i == 0)
		
		# 4b. Adiciona a referência da mão ao Mapa (O JEITO CERTO)
		map.player_hand.append(hand_instance)

		# 4c. Instancia a UI
		var ui_instance = player_ui_scene.instantiate()
		ui_instance.name = "PlayerUI_" + str(i)
		ui_instance.player_index = i
		
		# 4d. Pega os dados do Global e configura a UI
		var p_color = Global.get_participant_color(i)
		var p_name = Global.get_participant_display_name(i)
		ui_instance.set_player_info(p_color, p_name)
		
		player_uis.append(ui_instance)
		uis_container.add_child(ui_instance)
		ui_instance.visible = (i == 0)
		player_objectives[i] = []
	
	# --- PASSO 5: Instancia Mãos e UIs para as IAs
	for i in range(5 - Global.num_players):
		var ia_id = "ia_" + str(i)
		var ia_name = "IA " + str(i+1)
		var hand_instance = player_hand_scene.instantiate()
		hand_instance.name = "IAHand_" + str(i)
		iaHands.append(hand_instance)
		hands_container.add_child(hand_instance)
		hand_instance.visible = false
		player_objectives[ia_id] = []
		
		# 5c. Instancia a UI
		var ui_instance = player_ui_scene.instantiate()
		ui_instance.name = "IAUI_" + str(i)
		ui_instance.player_index = ia_id
		
		# 5d. Pega os dados do Global e configura a UI
		var p_color = Global.get_participant_color(ia_id)
		ui_instance.set_player_info(p_color, ia_name)
		
		player_uis.append(ui_instance)
		uis_container.add_child(ui_instance)
		#ui_instance.get_child(3).disabled = true # botão para checar objetivos
		#ui_instance.get_child(3).visible = false # botão para checar objetivos
		ui_instance.visible = false
	
	# --- PASSO 6: Atualizo o label padrao das UIs
	for i in range (len(player_uis)):
		player_uis[i].update_routes_display([])
	
	# --- PASSO 7: Atualizo a loja
	if loja_cards:
		loja_cards.deal_initial_cards()
	
func _on_map_route_claimed(player_index):
	print("TurnManager: Rota comprada recebida do jogador/IA: " + str(player_index))

	# Parte 1: Atualização da Interface
	var ui_to_update = null
	if player_index is int:
		# Se for jogador humano, pega a UI pelo índice direto
		if player_index < player_uis.size():
			ui_to_update = player_uis[player_index]
	else:
		# Se for IA, calcula o índice no array de UIs
		var ia_index_str = str(player_index).trim_prefix("ia_")
		if ia_index_str.is_valid_int():
			var ia_index = ia_index_str.to_int()
			var ui_instance_index = Global.num_players + ia_index
			if ui_instance_index < player_uis.size():
				ui_to_update = player_uis[ui_instance_index]

	# Se encontramos uma UI válida, mandamos ela atualizar TUDO
	if ui_to_update != null:
		var routes = map.player_claimed_routes.get(player_index, [])
		ui_to_update.update_routes_display(routes)
		ui_to_update.update_objectives_display()

	# Parte 2: Lógica de Fim de Jogo (executa para TODOS, humanos e IAs)
	if is_game_over:
		return # Não faz mais verificações se o jogo já terminou

	var all_objectives_completed = false
	
	# A verificação a seguir funciona com 'player_index' sendo int ou string
	if player_objectives.has(player_index) and not player_objectives[player_index].is_empty():
		if player_uis[index_player].concluidos.text == "2":
			all_objectives_completed = true

	# Se, após a verificação, todos os objetivos estiverem completos...
	if all_objectives_completed:
		if player_index is int:
			print("CONDIÇÃO DE FIM DE JOGO ATINGIDA PELO JOGADOR/IA: " + str(player_index))
		else:
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
	
	var message = "\n[center][font_size=36]Fim de Jogo![/font_size][/center]\n"
	message += "[center][font_size=28]Pontuações Finais:[/font_size][/center]\n"
	for id in final_scores:
		message += "[center][font_size=28] - Jogador {id}: {final_scores[id]} pontos[/font_size][/center]\n".format({"id": id, "final_scores[id]": final_scores[id]})
		
	message += "\n[center][font_size=28][b]O vencedor é o Jogador {winner_id} com {final_scores[winner_id]} pontos![/b][/font_size][/center]".format({"winner_id": winner_id, "final_scores[winner_id]": final_scores[winner_id]})
	
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
			var card_path = objective_texture.resource_path.get_file()
			if map.objective_card_data.has(card_path):
				var info = map.objective_card_data[card_path]
				var points = info["points"]
				var from_city = info["from"]
				var to_city = info["to"]
				
				if player_id is int:
					if map.is_objective_complete(player_id, from_city, to_city):
						total_score += points # Soma pontos se o objetivo foi completo
					else:
						total_score -= points # SUBTRAI pontos se não foi completo
					
	return total_score

func _on_deck_card_drawn(card_identifier: String):
	if cards_drawn_this_turn >= 2: 
		return

	if cards_drawn_this_turn == 0:
		current_state = State.DRAWING_CARDS
		map.set_route_claiming_enabled(false) # Bloqueia compra de rotas
	
	playerHands[index_player].add_card_to_hand(card_identifier)
	cards_drawn_this_turn += 1
	var selected_data = loja_cards.get_and_clear_selection()
	check_card_draw_limit()

func _on_shop_draw_button_pressed():
	if cards_drawn_this_turn >= 2: 
		loja_cards.finish_shop()
		check_card_draw_limit()
		map.set_route_claiming_enabled(true)
		return

	var selected_data = loja_cards.get_and_clear_selection()

	if selected_data.is_empty():
		print("Nenhuma carta da loja selecionada.")
		return

	if cards_drawn_this_turn + selected_data.size() > 2:
		print("Ação inválida: Você não pode comprar essa quantidade de cartas.")
		# Opcional: mostrar um pop-up de erro para o jogador
		return
	
	if cards_drawn_this_turn == 0:
		current_state = State.DRAWING_CARDS
		map.set_route_claiming_enabled(false) # Bloqueia compra de rotas

	for card_data in selected_data:
		deck.remove_card_from_deck()
		playerHands[index_player].add_card_to_hand(card_data.carta_clicada)
		loja_cards.replace_card(card_data)
		cards_drawn_this_turn += 1
		if card_data.carta_clicada == "rainbowTrain":
			cards_drawn_this_turn = 2
		if cards_drawn_this_turn >= 2:
			loja_cards.finish_shop()
			check_card_draw_limit()
			map.set_route_claiming_enabled(true)
			return
	
	check_card_draw_limit()

func check_card_draw_limit():
	if cards_drawn_this_turn >= 2:
		print("Limite de compra de cartas atingido.")
		deck_collision_shape.disabled = true
		loja_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
		loja_cards.finish_shop()
		map.set_route_claiming_enabled(true)
		end_turn_button.disabled = false

func _on_end_turn_button_pressed() -> void:
	# Verifica se ainda há um próximo jogador humano no turno
	if index_player + 1 < Global.num_players:
		deck_collision_shape.disabled = false
		index_player += 1
		change_player_hand()
		for card_node in selected_shop_cards:
			loja_cards._atualizar_borda_loja(card_node, false)
		selected_shop_cards.clear()
		cards_drawn_this_turn = 0
		if loja_cards:
			loja_cards.deal_initial_cards()
			loja_cards.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		if loja_cards:
			loja_cards.finish_shop()
			loja_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	# 1. Esconde a UI do último jogador humano antes de começar os turnos das IAs
	if index_player < player_uis.size():
		player_uis[index_player].visible = false

	# 2. Passa por cada IA, uma de cada vez
	for i in range(len(iaHands)):
		var current_ia_hand = iaHands[i]
		
		# Encontra o índice da UI da IA no array 'player_uis'
		var ui_instance_index = Global.num_players + i
		
		if ui_instance_index < player_uis.size():
			# 3. Mostra a UI da IA que está jogando
			player_uis[ui_instance_index].visible = true
		
		print("IA " + str(i+1) + " está pensando...")
		$"../EnemyThinking".start()
		await $"../EnemyThinking".timeout
		
		# 4. A IA joga o turno
		opponents_ai_turn(i, current_ia_hand)
		print("IA " + str(i+1) + " agiu!")
		
		await get_tree().create_timer(1.0).timeout
		
		# 5. Esconde a UI da IA que acabou de jogar, antes de passar para a próxima
		if ui_instance_index < player_uis.size():
			player_uis[ui_instance_index].visible = false

	# 6. Todos os turnos da IA acabaram, volta para o primeiro jogador
	print("Turno dos jogadores recomeçando.")
	round_idx += 1
	index_player = 0
	change_player_hand()
	for card_node in selected_shop_cards:
		loja_cards._atualizar_borda_loja(card_node, false)
	cards_drawn_this_turn = 0
	if loja_cards:
		loja_cards.deal_initial_cards()
		loja_cards.mouse_filter = Control.MOUSE_FILTER_STOP
	
	end_turn_button.disabled = false
	end_turn_button.visible = true

# Esta função agora é focada apenas em preparar o turno do jogador humano
func change_player_hand() -> void:
	# 1. Garante que todas as UIs estejam escondidas por padrão
	for ui in player_uis:
		ui.visible = false
	
	# Esconde todas as mãos
	for hand in playerHands:
		hand.visible = false

	# 2. Mostra a UI e a mão apenas do jogador humano ativo
	if index_player < playerHands.size():
		playerHands[index_player].visible = true
	
	if index_player < player_uis.size():
		var current_ui = player_uis[index_player]
		current_ui.visible = true
		print("Iniciando turno do Jogador " + str(index_player + 1))
		
		# 3. Garante que a UI esteja sempre atualizada no começo do turno dele
		var routes = map.player_claimed_routes.get(index_player, [])
		current_ui.update_routes_display(routes)
		current_ui.update_objective_counts()

	# 4. Lógica de início de turno (seleção de objetivos)
	if player_objectives[index_player].is_empty():
		print("Primeira rodada do jogador. Iniciando seleção de objetivos.")
		current_state = State.CHOOSING_OBJECTIVES
		end_turn_button.disabled = true
		if deck_collision_shape: 
			deck_collision_shape.disabled = true
		manager_objetivos.iniciar_selecao_de_objetivos()
	else:
		print("Jogador já possui objetivos. Iniciando turno normal.")
		current_state = State.PLAYER_TURN
		end_turn_button.disabled = true
		if deck_collision_shape: 
			deck_collision_shape.disabled = false

func _ai_can_afford_route(hand_node, route_data: Dictionary) -> bool:
	var cost = route_data.cost
	var color_str = route_data.color
	var card_key = map.color_name_to_card_key(color_str)
	var rainbow_count = hand_node.player_hand["rainbowTrain"]["count"]

	if card_key == "whiteTrain":
		# Para rotas brancas, a IA precisa de qualquer cor ou coringas
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
	
	if card_key == "whiteTrain":
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
	var difficult = "facil" if Global.difficult == 0 else "dificil"
	difficult = "medio" if Global.difficult == 1 else "dificil"
	print("--- INÍCIO TURNO: IA " + str(ia_index) + " (Dificuldade: " + difficult + ") ---")

	# 1. Lógica de escolher objetivos (só na primeira rodada)
	if player_objectives[ia_id].is_empty():
		print("IA " + str(ia_index) + " está escolhendo seus objetivos iniciais.")
		var objetivos_da_ia = manager_objetivos.get_random_objectives(2)
		player_objectives[ia_id] = objetivos_da_ia
		print("IA " + str(ia_index) + " escolheu " + str(objetivos_da_ia.size()) + " objetivos.")
		
		var ui_instance_index = Global.num_players + ia_index
		if ui_instance_index < player_uis.size():
			player_uis[ui_instance_index].add_objetivos(objetivos_da_ia)
		
	# 2. A IA sempre compra duas cartas no início do turno
	if deck.has_method("draw_card_for_ia"):
		var drawn_card = deck.draw_card_for_ia()
		var drawn_card2 = deck.draw_card_for_ia()
		if drawn_card:
			ia_hand_node.add_card_to_hand(drawn_card)
			ia_hand_node.add_card_to_hand(drawn_card2)
			print("IA " + str(ia_index) + " comprou a carta: {drawn_card}")

	# 3. Despachante de Dificuldade
	if Global.difficult == 0:
		_run_easy_ai_turn(ia_index, ia_hand_node)
	elif Global.difficult == 2:
		_run_hard_ai_turn(ia_index, ia_hand_node)
	else: # Dificuldade Média ou Padrão pode ser a fácil
		_run_easy_ai_turn(ia_index, ia_hand_node)

# LÓGICA DA IA FÁCIL
func _run_easy_ai_turn(ia_index: int, ia_hand_node):
	var ia_id = "ia_" + str(ia_index)
	
	var wishlist = _get_ai_objective_wishlist(ia_id)
	print("IA(Fácil) " + str(ia_index) + " tem " + str(wishlist.size()) + " rotas na sua lista de desejos.")

	var all_routes_claimed = false
	for route_data in wishlist:
		var route_node = map.get_route_node_by_data(route_data)
		if route_node and not route_node.claimed:
			if _ai_can_afford_route(ia_hand_node, route_data):
				print("IA (Fácil) " + str(ia_index+1) + " vai comprar a rota de " + route_data.from + " - " + route_data.to)
				_ai_pay_for_route(ia_hand_node, route_data)
				map.claim_route_for_player(route_node, ia_id)
				print("--- FIM TURNO: IA " + str(ia_index+1) + " (comprou uma rota) ---")
				map.get_child(0).text = "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (comprou uma rota)\n" + map.get_child(0).text
				return
		else:
			if route_node.claimed:
				all_routes_claimed = true
			else:
				all_routes_claimed = false
	
	if all_routes_claimed:
		end_game()
	player_uis[Global.num_players + ia_index].update_objectives_display()
	print("--- FIM TURNO: IA " + str(ia_index+1) + " (não comprou nada) ---")
	map.get_child(0).text = "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (não comprou uma rota)\n" + map.get_child(0).text

# LÓGICA DA IA DIFÍCIL
func _run_hard_ai_turn(ia_index: int, ia_hand_node):
	var ia_id = "ia_" + str(ia_index)

	# Fase 1: Ofensiva - Tenta jogar para seus próprios objetivos primeiro
	var offensive_wishlist = _get_ai_objective_wishlist(ia_id)
	for route_data in offensive_wishlist:
		var route_node = map.get_route_node_by_data(route_data)
		if route_node and not route_node.claimed:
			if _ai_can_afford_route(ia_hand_node, route_data):
				print("IA (Difícil) " + str(ia_index+1) + " [JOGADA OFENSIVA] para a rota " + route_data.from + " - " + route_data.to)
				_ai_pay_for_route(ia_hand_node, route_data)
				map.claim_route_for_player(route_node, ia_id)
				print("--- FIM TURNO: IA " + str(ia_index+1) + " (comprou rota ofensiva) ---")
				map.get_child(0).text = "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (comprou rota ofensiva)\n" + map.get_child(0).text
				return

	# Fase 2: Defensiva - Se não conseguiu jogar para si, tenta atrapalhar
	print("IA (Difícil) " + str(ia_index+1) + " não pôde fazer jogada ofensiva. Entrando em modo de sabotagem.")
	var target_player_index = _get_leading_human_player_index()
	if target_player_index != -1:
		# Lista de rotas para bloquear: primeiro as de alto valor, depois as adjacentes ao líder
		var blocking_wishlist = map.high_value_routes_to_block.duplicate()
		blocking_wishlist.append_array(map.get_all_unclaimed_routes_adjacent_to_player(target_player_index))
		
		for route_data in blocking_wishlist:
			var route_node = map.get_route_node_by_data(route_data)
			if route_node and not route_node.claimed:
				if _ai_can_afford_route(ia_hand_node, route_data):
					print("IA (Difícil) " + str(ia_index+1) + " [JOGADA DEFENSIVA] para bloquear Jogador " + str(target_player_index) + " na rota " + route_data.from + " - " + route_data.to)
					_ai_pay_for_route(ia_hand_node, route_data)
					map.claim_route_for_player(route_node, ia_id)
					print("--- FIM TURNO: IA " + str(ia_index+1) + " (comprou rota defensiva) ---")
					map.get_child(0).text = "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (comprou rota defensiva)\n" + map.get_child(0).text
					return
	
	player_uis[Global.num_players + ia_index].update_objectives_display()
	print("--- FIM TURNO: IA " + str(ia_index+1) + " (não comprou nada) ---")
	map.get_child(0).text = "Round " + str(round_idx)  + ": IA " + str(ia_index+1) + " (não comprou uma rota)\n" + map.get_child(0).text

# Função auxiliar para pegar a lista de desejos da IA
func _get_ai_objective_wishlist(ia_id: String) -> Array:
	var wishlist: Array = []
	if not player_objectives.has(ia_id): return wishlist

	for objective_texture in player_objectives[ia_id]:
		var card_path = objective_texture.resource_path
		if map.objective_card_data.has(card_path):
			var info = map.objective_card_data[card_path]
			var routes_for_objective = map.find_shortest_path_routes(info.from, info.to)
			if routes_for_objective:
				for r in routes_for_objective:
					if not r in wishlist:
						wishlist.append(r)
	return wishlist

# Função auxiliar para encontrar o jogador humano com maior pontuação
func _get_leading_human_player_index() -> int:
	var leading_player = -1
	var highest_score = -INF
	for i in range(Global.num_players):
		var score = calculate_player_score(i)
		if score > highest_score:
			highest_score = score
			leading_player = i
	return leading_player
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if deck and deck.is_connected("update_player_hand", Callable(self, "_on_deck_card_drawn")):
			deck.update_player_hand.disconnect(_on_deck_card_drawn)
			print("TurnManager desconectado do Deck com segurança.")
