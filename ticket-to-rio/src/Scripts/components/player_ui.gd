extends Control

var meus_objetivos_selecionados: Array[Texture2D] = []

var player_index: int = -1 # Armazenará o índice do jogador dono desta UI
@onready var map_node = get_node("/root/TutorialTest/Map")

@onready var concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Text
@onready var nao_concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/Text
@onready var objectives_container = $PanelContainer/ScrollContainer/VBoxContainer

@onready var purchased_routes_label: RichTextLabel = $RoutesLabel

func set_player_info(color: Color, player_name: String):
	$PlayerColorIndicator.color = color
	$RichTextLabel.text = "[center][b]" + player_name + "[/b][/center]"
		
func update_routes_display(player_routes: Array):
	if not purchased_routes_label:
		return

	if player_routes.is_empty():
		purchased_routes_label.text = "Nenhuma rota comprada."
		return

	var routes_as_strings: Array[String] = []
	for route_dict in player_routes:
		var from_city = route_dict["from"]
		var to_city = route_dict["to"]
		routes_as_strings.append("- {from_city} para {to_city}".format({"from_city": from_city, "to_city": to_city}))
	
	purchased_routes_label.text = "[b]Rotas Compradas:[/b]\n" + "\n".join(routes_as_strings)

# O TurnManager vai chamar esta função para entregar os objetivos.
func add_objetivos(novos_objetivos: Array[Texture2D]):
	for textura in novos_objetivos:
		meus_objetivos_selecionados.append(textura)
	
	# Atualiza o contador de objetivos não concluídos
	nao_concluidos.text = str(meus_objetivos_selecionados.size())
	print("%s recebeu %d novos objetivos!" % [name, novos_objetivos.size()])
	
	update_objective_counts()

func _on_objetivos_jogador_pressed() -> void:
	var janela_objetivos = $PanelContainer
	janela_objetivos.visible = not janela_objetivos.visible

	if janela_objetivos.visible:
		update_objectives_display()

func update_objectives_display():
	var objective_rects = objectives_container.get_children()
	
	# Atualiza a cor de cada carta de objetivo
	for i in range(objective_rects.size()):
		var rect: TextureRect = objective_rects[i]
		if i < meus_objetivos_selecionados.size():
			var textura = meus_objetivos_selecionados[i]
			rect.texture = textura
			
			var card_path = textura.resource_path
			if map_node.objective_card_data.has(card_path):
				var info = map_node.objective_card_data[card_path]
				if map_node.is_objective_complete(player_index, info.from, info.to):
					rect.modulate = Color.LIGHT_GREEN # Completo
				else:
					rect.modulate = Color.WHITE # Incompleto
			else:
				rect.modulate = Color.WHITE
		else:
			rect.texture = null
			rect.modulate = Color.WHITE
	
	# Após atualizar os visuais, recalcula e atualiza os contadores de texto
	update_objective_counts()


# NOVA FUNÇÃO: Calcula e atualiza os labels de texto
func update_objective_counts():
	if meus_objetivos_selecionados.is_empty():
		if concluidos: concluidos.text = "0"
		if nao_concluidos: nao_concluidos.text = "0"
		return

	var completed_count = 0
	# Passa por todos os objetivos e conta quantos estão completos
	for objective_texture in meus_objetivos_selecionados:
		var card_path = objective_texture.resource_path
		if map_node.objective_card_data.has(card_path):
			var info = map_node.objective_card_data[card_path]
			if map_node.is_objective_complete(player_index, info.from, info.to):
				completed_count += 1
	
	# Finalmente, atualiza os labels de texto com os valores corretos
	if concluidos:
		concluidos.text = str(completed_count)
	if nao_concluidos:
		nao_concluidos.text = str(meus_objetivos_selecionados.size() - completed_count)
