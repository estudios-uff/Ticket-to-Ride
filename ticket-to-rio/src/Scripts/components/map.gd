extends Node2D

# Preload das cenas das subcenas
var city_scene: PackedScene = preload("res://src/Scenes/TestMap/City.tscn")
var route_scene: PackedScene = preload("res://src/Scenes/TestMap/Route.tscn")
var info_popup_scene: PackedScene = preload("res://src/Scenes/TestMap/InfoPopup.tscn")
var cities: Dictionary = {} # Armazenará as instâncias das cidades (nome: nó_da_cidade)

# Dados de exemplo do mapa (pode vir de um arquivo JSON/CSV em um jogo real)
var map_data = {
	"cities": {
		"Barra Mansa": {
			"x": 58,
			"y": 244
		},
		"Barra do Piraí": {
			"x": 286,
			"y": 195
		},
		"Duque de Caxias": {
			"x": 630,
			"y": 404
		},
		"Guapimirim": {
			"x": 850,
			"y": 238
		},
		"Itaboraí": {
			"x": 932,
			"y": 377
		},
		"Itaguaí": {
			"x": 321,
			"y": 452
		},
		"Japeri": {
			"x": 401,
			"y": 306
		},
		"Maricá": {
			"x": 960,
			"y": 493
		},
		"Miguel Pereira": {
			"x": 525,
			"y": 183
		},
		"Niterói": {
			"x": 769,
			"y": 467
		},
		"Nova Cidade 6": {
			"x": 1181,
			"y": 561
		},
		"Nova Iguaçu": {
			"x": 536,
			"y": 386
		},
		"Paracambi": {
			"x": 364,
			"y": 287
		},
		"Petrópolis": {
			"x": 719,
			"y": 217
		},
		"Pinheiral": {
			"x": 169,
			"y": 223
		},
		"Piraí": {
			"x": 240,
			"y": 300
		},
		"Queimados": {
			"x": 467,
			"y": 358
		},
		"Rio de Janeiro": {
			"x": 717,
			"y": 485
		},
		"Seropédica": {
			"x": 364,
			"y": 378
		},
		"Tanguá": {
			"x": 1028,
			"y": 369
		},
		"Teresópolis": {
			"x": 853,
			"y": 159
		},
		"Valença": {
			"x": 369,
			"y": 47
		},
		"Vassouras": {
			"x": 394,
			"y": 151
		},
		"Volta Redonda": {
			"x": 103,
			"y": 231
		}
	},
	"routes": [
		{"from": "Barra Mansa", "to": "Volta Redonda", "color": "yellow", "cost": 1},
		{"from": "Barra Mansa", "to": "Piraí", "color": "green", "cost": 6},
		{"from": "Volta Redonda", "to": "Pinheral", "color": "pink", "cost": 2},
		{"from": "Pinheral", "to": "Barra do Piraí", "color": "blue", "cost": 4},
		{"from": "Pinheral", "to": "Piraí", "color": "grey", "cost": 3},
		
	]
}

func _ready():
	draw_map()

func draw_map():
	# 1. Instanciar Cidades
	for city_name in map_data["cities"]:
		var city_data = map_data["cities"][city_name]
		var city_instance = city_scene.instantiate()
		city_instance.city_name = city_name
		add_child(city_instance) # Adiciona como filho do Map

		city_instance.position = Vector2(city_data.x, city_data.y)
		cities[city_name] = city_instance # Armazena a referência para a cidade
		city_instance.z_index = 2

		# Conecta o sinal 'city_clicked' da cidade
		city_instance.city_clicked.connect(_on_city_clicked)

	# 2. Instanciar Rotas
	for route_data in map_data["routes"]:
		var from_city_name = route_data.from
		var to_city_name = route_data.to

		if cities.has(from_city_name) and cities.has(to_city_name):
			var from_city_node = cities[from_city_name]
			var to_city_node = cities[to_city_name]

			var route_instance = route_scene.instantiate()
			add_child(route_instance) # Adiciona como filho do Map
			
			# Configura a rota usando a função setup_route
			route_instance.setup_route(from_city_node, to_city_node, parse_color(route_data.color), route_data.cost)
			route_instance.from_city_name = from_city_name # Para depuração
			route_instance.to_city_name = to_city_name   # Para depuração

			# Conecta o sinal 'route_clicked' da rota
			route_instance.route_clicked.connect(_on_route_clicked)
			route_instance.z_index = 1
		else:
			push_error("Erro: Cidade não encontrada para rota: ", from_city_name, " ou ", to_city_name)

# Função auxiliar para converter string de cor para objeto Color
func parse_color(color_string: String) -> Color:
	const ALPHA_VALUE: float = 0.2

	match color_string.to_lower():
		"red": return Color(Color.RED.r, Color.RED.g, Color.RED.b, ALPHA_VALUE)
		"blue": return Color(Color.BLUE.r, Color.BLUE.g, Color.BLUE.b, ALPHA_VALUE)
		"green": return Color(Color.GREEN.r, Color.GREEN.g, Color.GREEN.b, ALPHA_VALUE)
		"yellow": return Color(Color.YELLOW.r, Color.YELLOW.g, Color.YELLOW.b, ALPHA_VALUE)
		"orange": return Color(1.0, 0.5, 0.0, ALPHA_VALUE) # Laranja
		"purple": return Color(0.5, 0.0, 0.5, ALPHA_VALUE) # Roxo
		"black": return Color(Color.BLACK.r, Color.BLACK.g, Color.BLACK.b, ALPHA_VALUE)
		"white": return Color(Color.WHITE.r, Color.WHITE.g, Color.WHITE.b, ALPHA_VALUE)
		"gray": return Color(Color.GRAY.r, Color.GRAY.g, Color.GRAY.b, ALPHA_VALUE)
		"pink": return Color(1.0, 0.75, 0.8, ALPHA_VALUE) # Rosa
		_: return Color(Color.WHITE.r, Color.WHITE.g, Color.WHITE.b, ALPHA_VALUE)  # Padrão para branco se a cor não for reconhecida


func show_info_popup(message: String, global_position: Vector2):
	var popup_instance = info_popup_scene.instantiate()
	add_child(popup_instance) # Adiciona o pop-up como filho do Map (ou de uma camada UI)

	# Ajusta a posição do pop-up para que ele apareça próximo ao clique
	# Pode ser necessário ajustar o offset para centralizar o pop-up
	var popup_offset = Vector2(popup_instance.size.x / 2, popup_instance.size.y / 2) # Para centralizar o pop-up
	popup_instance.show_message(message, global_position - popup_offset)
	# Se o pop-up não tem um tamanho definido na cena, você pode precisar de um Frame ou de um Control
	# que auto-expanda para que popup_instance.size.x e y sejam válidos.
	# Caso contrário, apenas posicione sem offset inicialmente para testar.
	# popup_instance.show_message(message, global_position)

# Funções de callback para os sinais de clique
func _on_city_clicked(city_node: Node2D):
	print("Mapa recebeu clique na cidade: ", city_node.city_name)
	show_info_popup("Cidade Clicada: " + city_node.city_name, city_node.position)
	# Lógica do jogo aqui (ex: destacar cidade para construir rota)

func _on_route_clicked(route_node: Node2D):
	print("Mapa recebeu clique na rota: ", route_node.from_city_name, " - ", route_node.to_city_name, " (Custo: ", route_node.wagon_cost, ")")
	# Exemplo: Simular que o jogador reivindicou a rota (muda a cor dos vagões)
	# Em um jogo real, você verificaria se o jogador tem os vagões e cartas de trem necessários.
	var player_color = Color.GREEN # Exemplo: Cor do jogador
	route_node.set_wagons_player_color(player_color)
