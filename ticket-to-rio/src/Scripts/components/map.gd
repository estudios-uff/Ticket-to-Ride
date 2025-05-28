extends Node2D

# Preload das cenas das subcenas
var city_scene: PackedScene = preload("res://src/Scenes/TestMap/City.tscn")
var route_scene: PackedScene = preload("res://src/Scenes/TestMap/Route.tscn")

var cities: Dictionary = {} # Armazenará as instâncias das cidades (nome: nó_da_cidade)

# Dados de exemplo do mapa (pode vir de um arquivo JSON/CSV em um jogo real)
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

# Funções de callback para os sinais de clique
func _on_city_clicked(city_node: Node2D):
	print("Mapa recebeu clique na cidade: ", city_node.city_name)
	# Lógica do jogo aqui (ex: destacar cidade para construir rota)

func _on_route_clicked(route_node: Node2D):
	print("Mapa recebeu clique na rota: ", route_node.from_city_name, " - ", route_node.to_city_name, " (Custo: ", route_node.wagon_cost, ")")
	# Exemplo: Simular que o jogador reivindicou a rota (muda a cor dos vagões)
	# Em um jogo real, você verificaria se o jogador tem os vagões e cartas de trem necessários.
	var player_color = Color.GREEN # Exemplo: Cor do jogador
	route_node.set_wagons_player_color(player_color)
