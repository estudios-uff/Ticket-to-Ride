extends Node2D

@onready var map_display: Control = $MapDisplay
@onready var ui_container: Control = $UIContainer
@onready var btn_create_city: Button = $UIContainer/VBoxContainer/BtnCreateCity
@onready var btn_create_route: Button = $UIContainer/VBoxContainer/BtnCreateRoute
@onready var btn_move: Button = $UIContainer/VBoxContainer/BtnMove
@onready var btn_save_map: Button = $UIContainer/VBoxContainer/BtnSaveMap
@onready var btn_load_map: Button = $UIContainer/VBoxContainer/BtnLoadMap

@onready var properties_panel: PanelContainer = $UIContainer/PropertiesPanel
@onready var line_edit_name: LineEdit = $UIContainer/PropertiesPanel/VBoxContainer/HBoxContainer/LineEditName
@onready var spin_box_cost: SpinBox = $UIContainer/PropertiesPanel/VBoxContainer/HBoxContainer2/SpinBoxCost
@onready var color_picker_button_route: ColorPickerButton = $UIContainer/PropertiesPanel/VBoxContainer/HBoxContainer3/ColorPickerButtonRoute
@onready var btn_apply_properties: Button = $UIContainer/PropertiesPanel/VBoxContainer/BtnApplyProperties


var city_scene: PackedScene = preload("res://src/Scenes/TestMap/City.tscn")
var route_scene: PackedScene = preload("res://src/Scenes/TestMap/Route.tscn")

enum EditorMode {
	NONE,
	CREATE_CITY,
	CREATE_ROUTE_SELECT_START,
	CREATE_ROUTE_SELECT_END,
	MOVE
}

var current_mode: EditorMode = EditorMode.NONE
var selected_node: Node = null # O nó (cidade ou rota) atualmente selecionado
var first_city_for_route: Node2D = null # Para criação de rota

var cities_data: Dictionary = {} # Guarda dados de cidades (nome: {x, y})
var routes_data: Array = [] # Guarda dados de rotas ({from, to, color, cost})

func _ready():
	#pass
	# Conectar sinais dos botões da UI
	btn_create_city.pressed.connect(func(): set_mode(EditorMode.CREATE_CITY))
	btn_create_route.pressed.connect(func(): set_mode(EditorMode.CREATE_ROUTE_SELECT_START))
	btn_move.pressed.connect(func(): set_mode(EditorMode.MOVE))
	btn_save_map.pressed.connect(save_map_data)
	btn_load_map.pressed.connect(load_map_data)
	btn_apply_properties.pressed.connect(apply_properties_to_selected_node)
	
	map_display.gui_input.connect(_on_map_display_gui_input)
	# Esconder o painel de propriedades inicialmente
	#properties_panel.hide()

	# Carregar um mapa inicial (se houver)
	load_map_data() # Tenta carregar um mapa padrão ao iniciar

func set_mode(mode: EditorMode):
	current_mode = mode
	print("Modo de edição: ", EditorMode.keys()[mode])
	# Resetar estado de criação de rota
	first_city_for_route = null
	update_ui_mode_feedback()

func update_ui_mode_feedback():
	# Adicione feedback visual aos botões aqui (ex: mudar cor, pressionar)
	btn_create_city.button_pressed = (current_mode == EditorMode.CREATE_CITY)
	btn_create_route.button_pressed = (current_mode == EditorMode.CREATE_ROUTE_SELECT_START || current_mode == EditorMode.CREATE_ROUTE_SELECT_END)
	btn_move.button_pressed = (current_mode == EditorMode.MOVE)

func _input(event: InputEvent):
	# Lógica para criação de cidade
	if current_mode == EditorMode.CREATE_CITY and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		create_city_at_mouse_position(event.position)

	# Lógica para mover cidades (seleciona a cidade)
	if current_mode == EditorMode.MOVE and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var clicked_node = get_node_at_mouse_position(event.position)
		if clicked_node and clicked_node is City:
			select_node(clicked_node) # Seleciona para mover ou editar propriedades
			# A lógica de arrastar já está no City.gd, só precisamos selecionar


@warning_ignore("shadowed_variable_base_class")
func create_city_at_mouse_position(position: Vector2):
	var new_city_instance = city_scene.instantiate()
	new_city_instance.position = position
	new_city_instance.city_name = "Nova Cidade " + str(cities_data.size())
	new_city_instance.editor_mode = true # Ativa o modo editor para a cidade
	map_display.add_child(new_city_instance)
	cities_data[new_city_instance.city_name] = {"x": position.x, "y": position.y}

	new_city_instance.city_clicked.connect(_on_city_clicked_editor)
	new_city_instance.city_moved.connect(_on_city_moved_editor)

	select_node(new_city_instance) # Seleciona a cidade recém-criada
	set_mode(EditorMode.NONE) # Volta para o modo padrão ou Move

func create_route(city1: Node2D, city2: Node2D):
	# Evita rota com a mesma cidade ou rota duplicada
	if city1 == city2:
		print("Não é possível criar rota para a mesma cidade.")
		return
	
	# Normaliza a ordem para checagem de duplicidade
	var city_names_to_sort = [city1.city_name, city2.city_name]
	city_names_to_sort.sort() 
	var sorted_city_names = city_names_to_sort
	
	var existing_route = false
	for r_data in routes_data:
		var route_names_to_sort = [r_data.from, r_data.to]
		route_names_to_sort.sort()
		var r_sorted_names = route_names_to_sort
		if r_sorted_names[0] == sorted_city_names[0] and r_sorted_names[1] == sorted_city_names[1]:
			existing_route = true
			break
	
	if existing_route:
		print("Rota entre ", city1.city_name, " e ", city2.city_name, " já existe.")
		return

	var new_route_instance = route_scene.instantiate()
	new_route_instance.setup_route(city1, city2, Color.WHITE, 1) # Cor padrão e custo
	new_route_instance.from_city_name = city1.city_name
	new_route_instance.to_city_name = city2.city_name
	map_display.add_child(new_route_instance)
	
	# Adicionar aos dados do mapa
	routes_data.append({"from": city1.city_name, "to": city2.city_name, "color": "white", "cost": 1})

	new_route_instance.route_clicked.connect(_on_route_clicked_editor)
	
	print("Rota criada entre ", city1.city_name, " e ", city2.city_name)
	set_mode(EditorMode.NONE)
	select_node(new_route_instance) # Seleciona a rota recém-criada

# Função para obter o nó clicado
func get_node_at_mouse_position(global_pos: Vector2) -> Node:
	var clicked_nodes = []
	# Verifica cidades
	for city_name in cities_data:
		var city_node = map_display.get_node(city_name) # Assuming city names are node names
		if city_node and city_node is City and city_node.get_rect().has_point(city_node.to_local(global_pos)):
			clicked_nodes.append(city_node)
	
	# Verifica rotas (precisa de um mecanismo de colisão ativa ou iteração mais complexa)
	# Por simplicidade, vamos depender dos sinais de Area2D para rotas clicadas.
	# Esta função é mais para a seleção "manual" no modo MOVE/SELECT

	# Retorna o primeiro nó clicado (priorizando cidades se houver sobreposição)
	if not clicked_nodes.is_empty():
		return clicked_nodes[0]
	return null

func select_node(node_to_select: Node):
	# Deseleciona o nó anterior
	if selected_node:
		if selected_node is Line2D: # Ou sua cena Route
			selected_node.modulate = Color.WHITE # Volta a cor normal
		elif selected_node is City:
			selected_node.modulate = Color.WHITE

	selected_node = node_to_select
	properties_panel.show()
	
	# Preencher UI com propriedades do nó selecionado
	if selected_node is City:
		selected_node.modulate = Color.CORNFLOWER_BLUE # Exemplo de destaque
		line_edit_name.text = selected_node.city_name
		#spin_box_cost.hide() # Cidades não tem custo
		#color_picker_button_route.hide() # Cidades não tem cor
	elif selected_node is Route:
		selected_node.modulate = Color.CORNFLOWER_BLUE # Exemplo de destaque
		line_edit_name.text = selected_node.from_city_name + " - " + selected_node.to_city_name
		spin_box_cost.show()
		spin_box_cost.value = selected_node.wagon_cost
		color_picker_button_route.show()
		color_picker_button_route.color = selected_node.route_color
	


func apply_properties_to_selected_node():
	if not selected_node: return

	if selected_node is City:
		var old_name = selected_node.city_name
		var new_name = line_edit_name.text

		if new_name != old_name:
			# Atualiza no dicionário de dados do mapa
			if cities_data.has(old_name):
				var city_data = cities_data[old_name]
				cities_data.erase(old_name)
				cities_data[new_name] = city_data
				selected_node.city_name = new_name # Atualiza o nome no nó
				selected_node.label_node.text = new_name # Atualiza o label diretamente
				selected_node.name = new_name # Renomeia o nó na SceneTree (útil para get_node)

				# Atualiza as rotas conectadas para usar o novo nome
				for route in map_display.get_children():
					if route is Route:
						if route.from_city_name == old_name:
							route.from_city_name = new_name
						if route.to_city_name == old_name:
							route.to_city_name = new_name
			else:
				push_error("Cidade selecionada não encontrada nos dados.")
		
	elif selected_node is Route:
		selected_node.wagon_cost = int(spin_box_cost.value)
		selected_node.route_color = color_picker_button_route.color
		selected_node.line_2d.default_color = selected_node.route_color
		selected_node.spawn_wagons() # Redesenha os vagões com o novo custo/cor
		selected_node.line_2d.queue_redraw() # Garante que a linha seja redesenhada com a nova cor

		# Atualiza nos dados do mapa
		for r_data in routes_data:
			if r_data.from == selected_node.from_city_name and r_data.to == selected_node.to_city_name:
				r_data.cost = selected_node.wagon_cost
				r_data.color = selected_node.route_color.to_html(false) # Salva a cor como string HTML
				break
	print("Propriedades aplicadas.")


# Funções de callback para cliques de cidades/rotas no editor
func _on_city_clicked_editor(city_node: City):
	print("MapEditor recebeu clique na cidade: ", city_node.city_name)
	if current_mode == EditorMode.CREATE_ROUTE_SELECT_START:
		first_city_for_route = city_node
		print("Primeira cidade selecionada para rota: ", city_node.city_name)
		set_mode(EditorMode.CREATE_ROUTE_SELECT_END)
	elif current_mode == EditorMode.CREATE_ROUTE_SELECT_END:
		if first_city_for_route and first_city_for_route != city_node:
			create_route(first_city_for_route, city_node)
		else:
			print("Selecione uma cidade diferente ou a mesma cidade novamente para cancelar a rota.")
			set_mode(EditorMode.NONE) # Cancelar seleção de rota
		first_city_for_route = null
	elif current_mode == EditorMode.NONE or current_mode == EditorMode.MOVE:
		select_node(city_node)

func _on_route_clicked_editor(route_node: Route):
	if current_mode == EditorMode.NONE or current_mode == EditorMode.MOVE:
		select_node(route_node)


# Função para lidar com o movimento da cidade e atualizar rotas conectadas
func _on_city_moved_editor(city_node: City):
	# Atualiza a posição nos dados do mapa
	if cities_data.has(city_node.city_name):
		cities_data[city_node.city_name].x = city_node.position.x
		cities_data[city_node.city_name].y = city_node.position.y
	
	# Atualiza as rotas conectadas
	for route in map_display.get_children():
		if route is Route:
			if route.from_city_node == city_node or route.to_city_node == city_node:
				route.update_route_visuals()
	print("Cidade ", city_node.city_name, " movida para ", city_node.position)


# Funções de Salvar/Carregar Mapa
func save_map_data():
	var save_path = "res://custom_map.json"
	var map_to_save = {
		"cities": {},
		"routes": []
	}

	# Coletar dados das cidades instanciadas
	for city_node in map_display.get_children():
		if city_node is City:
			map_to_save.cities[city_node.city_name] = {
				"x": city_node.position.x,
				"y": city_node.position.y
			}
	
	# Coletar dados das rotas instanciadas
	for route_node in map_display.get_children():
		if route_node is Route:
			map_to_save.routes.append({
				"from": route_node.from_city_name,
				"to": route_node.to_city_name,
				"color": route_node.route_color.to_html(false), # Salva a cor como string HTML
				"cost": route_node.wagon_cost
			})

	var json_string = JSON.stringify(map_to_save, "\t") # "\t" para indentação
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Mapa salvo em: ", save_path)
	else:
		push_error("Erro ao salvar mapa em: ", save_path)

func load_map_data():
	var load_path = "res://custom_map.json"
	var file = FileAccess.open(load_path, FileAccess.READ)
	var map_data = {
			"cities": {
			"New York": {"x": 20, "y": 200},
			"Boston": {"x": 250, "y": 150},
			"Washington": {"x": 200, "y": 300},
			"Miami": {"x": 300, "y": 500},
			"Chicago": {"x": 400, "y": 250},
			"Denver": {"x": 600, "y": 300},
			"Salt Lake City": {"x": 700, "y": 200},
			"San Francisco": {"x": 900, "y": 250},
			"Los Angeles": {"x": 950, "y": 400},
			"Seattle": {"x": 850, "y": 100}
		},
		"routes": [
			{"from": "New York", "to": "Boston", "color": "blue", "cost": 2},
			{"from": "New York", "to": "Washington", "color": "white", "cost": 2},
			{"from": "New York", "to": "Chicago", "color": "orange", "cost": 3},
			{"from": "Washington", "to": "Miami", "color": "red", "cost": 4},
			{"from": "Chicago", "to": "Denver", "color": "yellow", "cost": 4},
			{"from": "Denver", "to": "Salt Lake City", "color": "green", "cost": 3},
			{"from": "Salt Lake City", "to": "San Francisco", "color": "black", "cost": 5},
			{"from": "San Francisco", "to": "Los Angeles", "color": "purple", "cost": 1},
			{"from": "Los Angeles", "to": "Seattle", "color": "pink", "cost": 6}, 
			{"from": "Denver", "to": "Los Angeles", "color": "gray", "cost": 5}
		]
	}
	if not file:
		print("Arquivo de mapa não encontrado. Carregando dados padrão (map_data).")
		# Se não houver arquivo salvo, usa os dados padrão definidos no script
		#draw_map_from_data(map_data)
		return

	var content = file.get_as_text()
	file.close()
	var parsed_data = JSON.parse_string(content)

	if parsed_data is Dictionary:
		print("Mapa carregado de: ", load_path)
		draw_map_from_data(parsed_data)
	else:
		push_error("Erro ao parsear JSON do mapa: ", parsed_data)
		print("Carregando dados padrão (map_data) em vez disso.")
		draw_map_from_data(map_data)

func draw_map_from_data(data_to_draw: Dictionary):
	# Limpar mapa existente antes de carregar um novo
	for child in map_display.get_children():
		child.queue_free()
	
	cities_data.clear()
	routes_data.clear()

	# Instanciar Cidades
	for city_name_key in data_to_draw.cities:
		var city_data = data_to_draw.cities[city_name_key]
		var new_city_instance = city_scene.instantiate()
		new_city_instance.position = Vector2(city_data.x, city_data.y)
		new_city_instance.city_name = city_name_key
		new_city_instance.editor_mode = true # Ativa o modo editor
		new_city_instance.z_index = 2 # Cidades acima das rotas
		map_display.add_child(new_city_instance)
		
		cities_data[city_name_key] = city_data # Armazena nos dados do editor
		new_city_instance.city_clicked.connect(_on_city_clicked_editor)
		new_city_instance.city_moved.connect(_on_city_moved_editor)
		# Renomeia o nó na SceneTree para facilitar get_node()
		new_city_instance.name = city_name_key 

	# Instanciar Rotas
	for route_data_item in data_to_draw.routes:
		var from_city_name = route_data_item.from
		var to_city_name = route_data_item.to

		if cities_data.has(from_city_name) and cities_data.has(to_city_name):
			var from_city_node = map_display.get_node(from_city_name) # Obtém a instância da cidade
			var to_city_node = map_display.get_node(to_city_name) # Obtém a instância da cidade

			var new_route_instance = route_scene.instantiate()
			# Converte a cor de string HTML para Color
			var parsed_color = Color(route_data_item.color) 
			new_route_instance.setup_route(from_city_node, to_city_node, parsed_color, route_data_item.cost)
			new_route_instance.from_city_name = from_city_name
			new_route_instance.to_city_name = to_city_name
			new_route_instance.z_index = 1 # Rotas abaixo das cidades
			map_display.add_child(new_route_instance)
			
			routes_data.append(route_data_item) # Armazena nos dados do editor
			new_route_instance.route_clicked.connect(_on_route_clicked_editor)
		else:
			push_error("Erro ao carregar rota: Cidade não encontrada para ", from_city_name, " ou ", to_city_name)


# Função auxiliar para converter string de cor para objeto Color (igual ao do Map.gd original)
func parse_color(color_string: String) -> Color:
	match color_string.to_lower():
		"red": return Color.RED
		"blue": return Color.BLUE
		"green": return Color.GREEN
		"yellow": return Color.YELLOW
		"orange": return Color(1.0, 0.5, 0.0) # Laranja
		"purple": return Color(0.5, 0.0, 0.5) # Roxo
		"black": return Color.BLACK
		"white": return Color.WHITE
		"gray": return Color.GRAY
		"pink": return Color(1.0, 0.75, 0.8) # Rosa
		_: return Color.WHITE # Padrão para branco se a cor não for reconhecida


func _on_map_display_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = map_display.to_local(event.position)
			match current_mode:
				EditorMode.CREATE_CITY:
					create_city_at_mouse_position(click_pos)
				# CREATE_ROUTE é gerenciado pelos sinais de clique da cidade
				# MOVE é gerenciado pela lógica de arrastar da cidade
