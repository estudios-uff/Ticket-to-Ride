extends Node2D

# Preload das cenas das subcenas
var city_scene: PackedScene = preload("res://src/Scenes/TestMap/City.tscn")
var route_scene: PackedScene = preload("res://src/Scenes/TestMap/Route.tscn")
var info_popup_scene: PackedScene = preload("res://src/Scenes/TestMap/InfoPopup.tscn")
var cities: Dictionary = {} # Armazenará as instâncias das cidades (nome: nó_da_cidade)
var route_nodes: Dictionary = {}

@export var player_hand_path: String = "/root/TutorialTest/PlayerHandsContainer/PlayerHand"
@export var player_color: Color = Color.GREEN
@export var player_hand: Array[Node] = []

var player_claimed_routes: Dictionary = {} # Chave: player_index, Valor: Array de rotas

signal route_claimed(player_index)

var objective_card_data = {
	"res://images/cards/card (1).png": {"from": "Duque de Caxias", "to": "Petrópolis", "points": 8},
	"res://images/cards/card (2).png": {"from": "Valença", "to": "Miguel Pereira", "points": 9},
	"res://images/cards/card (3).png": {"from": "Niterói", "to": "Tanguá", "points": 9},
	"res://images/cards/card (4).png": {"from": "Piraí", "to": "Itaguaí", "points": 7},
	"res://images/cards/card (5).png": {"from": "Duque de Caxias", "to": "Petrópolis", "points": 8}, #### 1
	"res://images/cards/card (6).png": {"from": "Miguel Pereira", "to": "Nova Iguaçu", "points": 8},
	"res://images/cards/card (7).png": {"from": "Piraí", "to": "Barra de Piraí", "points": 8},
	"res://images/cards/card (8).png": {"from": "Seropédica", "to": "Vassouras", "points": 8},
	"res://images/cards/card (9).png": {"from": "Pinheiral", "to": "Japeri", "points": 8},
	"res://images/cards/card (10).png": {"from": "Queimados", "to": "Rio de Janeiro", "points": 9},
	"res://images/cards/card (11).png": {"from": "Barra de Piraí", "to": "Itaguaí", "points": 9},
	"res://images/cards/card (12).png": {"from": "Maricá", "to": "Tanguá", "points": 5},
	"res://images/cards/card (13).png": {"from": "Barra do Piraí", "to": "Valença", "points": 6},
	"res://images/cards/card (14).png": {"from": "Guapimirim", "to": "Itaboraí", "points": 6},
	"res://images/cards/card (15).png": {"from": "Barra Mansa", "to": "Piraí", "points": 6},
	"res://images/cards/card (16).png": {"from": "Niterói", "to": "Maricá", "points": 6},
	"res://images/cards/card (17).png": {"from": "Miguel Pereira", "to": "Petrópolis", "points": 7},
	"res://images/cards/card (18).png": {"from": "Japeri", "to": "Duque de Caxias", "points": 7},
	"res://images/cards/card (19).png": {"from": "Barra do Piraí", "to": "Queimados", "points": 7},
	"res://images/cards/card (20).png": {"from": "Japeri", "to": "Petrópolis", "points": 13},
	"res://images/cards/card (21).png": {"from": "Vassouras", "to": "Duque de Caxias", "points": 13},
	"res://images/cards/card (22).png": {"from": "Seropédica", "to": "Niterói", "points": 13},
	"res://images/cards/card (23).png": {"from": "Volta Redonda", "to": "Valença", "points": 13},
	"res://images/cards/card (24).png": {"from": "Barra Mansa", "to": "Itaguaí", "points": 13},
	"res://images/cards/card (25).png": {"from": "Petrópolis", "to": "Teresópolis", "points": 5},
	"res://images/cards/card (26).png": {"from": "Duque de Caxias", "to": "Niterói", "points": 5},
	"res://images/cards/card (27).png": {"from": "Itaguaí", "to": "Queimados", "points": 5},
	"res://images/cards/card (28).png": {"from": "Piraí", "to": "Petrópolis", "points": 18},
	"res://images/cards/card (29).png": {"from": "Barra Mansa", "to": "Duque de Caxias", "points": 18},
	"res://images/cards/card (30).png": {"from": "Pinheiral", "to": "Rio de Janeiro", "points": 19},
	"res://images/cards/card (31).png": {"from": "Volta Redonda", "to": "Rio de Janeiro", "points": 21},
	"res://images/cards/card (32).png": {"from": "Volta Redonda", "to": "Niterói", "points": 22},
	"res://images/cards/card (33).png": {"from": "Vassouras", "to": "Itaborái", "points": 22},
	"res://images/cards/card (34).png": {"from": "Valença", "to": "Niterói", "points": 22},
	"res://images/cards/card (35).png": {"from": "Rio de Janeiro", "to": "Guapimirim", "points": 13},
	"res://images/cards/card (36).png": {"from": "Volta Redonda", "to": "Valença", "points": 13},
	"res://images/cards/card (37).png": {"from": "Volta Redonda", "to": "Nova Iguaçu", "points": 14},
	"res://images/cards/card (38).png": {"from": "Niterói", "to": "Teresópolis", "points": 14},
	"res://images/cards/card (39).png": {"from": "Nova Iguaçu", "to": "Guapimirim", "points": 15},
	"res://images/cards/card (40).png": {"from": "Queimados", "to": "Itaboraí", "points": 16},
	"res://images/cards/card (41).png": {"from": "Volta Redonda", "to": "Miguel Pereira", "points": 16},
	"res://images/cards/card (42).png": {"from": "Volta Redonda", "to": "Duque de Caxias", "points": 17},
	"res://images/cards/card (43).png": {"from": "Barra de Piraí", "to": "Niterói", "points": 17},
	"res://images/cards/card (44).png": {"from": "Vassouras", "to": "Nova Iguaçu", "points": 10},
	"res://images/cards/card (45).png": {"from": "Volta Redonda", "to": "Seropédica", "points": 10},
	"res://images/cards/card (46).png": {"from": "Nova Iguaçu", "to": "Petrópolis", "points": 11},
	"res://images/cards/card (47).png": {"from": "Miguel Pereira", "to": "Duque de Caxias", "points": 11},
	"res://images/cards/card (48).png": {"from": "Vassouras", "to": "Petrópolis", "points": 12},
	"res://images/cards/card (49).png": {"from": "Pinheiral", "to": "Nova Iguaçu", "points": 12},
	"res://images/cards/card (50).png": {"from": "Japeri", "to": "Niterói", "points": 12},
	"res://images/cards/card (51).png": {"from": "Petrópolis", "to": "Niterói", "points": 13},
	"res://images/cards/card (52).png": {"from": "Niterói", "to": "Maricá", "points": 6}, #### 2
	"res://images/cards/card (53).png": {"from": "Nova Iguaçu", "to": "Rio de Janeiro", "points": 7},
	"res://images/cards/card (54).png": {"from": "Itaguaí", "to": "Nova Iguaçu", "points": 7},
	"res://images/cards/card (55).png": {"from": "Volta Redonda", "to": "Barra de Piraí", "points": 7},
	"res://images/cards/card (56).png": {"from": "Duque de Caxias", "to": "Petrópolis", "points": 8}, ### 1
	"res://images/cards/card (57).png": {"from": "Nova Iguaçu", "to": "Niterói", "points": 8},
	"res://images/cards/card (58).png": {"from": "Niterói", "to": "Tanguá", "points": 9},
	"res://images/cards/card (59).png": {"from": "Petrópolis", "to": "Itaboraí", "points": 10},
	"res://images/cards/card (60).png": {"from": "Paracambi", "to": "Tanguá", "points": 22},
	"res://images/cards/card (61).png": {"from": "Nova Iguaçu", "to": "Duque de Caxias", "points": 3},
	"res://images/cards/card (62).png": {"from": "Duque de Caxias", "to": "Rio de Janeiro", "points": 4},
	"res://images/cards/card (63).png": {"from": "Petrópolis", "to": "Teresópolis", "points": 5}, ### 3
	"res://images/cards/card (64).png": {"from": "Queimados", "to": "Duque de Caxias", "points": 5},
	"res://images/cards/card (65).png": {"from": "Volta Redonda", "to": "Piraí", "points": 5},
	"res://images/cards/card (66).png": {"from": "Guapimirim", "to": "Itaboraí", "points": 6}, ### 4
	"res://images/cards/card (67).png": {"from": "Niterói", "to": "Itaboraí", "points": 6},
	"res://images/cards/card (68).png": {"from": "Barra Mansa", "to": "Duque de Caxias", "points": 18},### 5
	"res://images/cards/card (69).png": {"from": "Seropédica", "to": "Maricá", "points": 19},
	"res://images/cards/card (70).png": {"from": "Volta Redonda", "to": "Rio de Janeiro", "points": 21},
	"res://images/cards/card (71).png": {"from": "Pinheiral", "to": "Petrópolis", "points": 21},
	"res://images/cards/card (72).png": {"from": "Barra do Piraí", "to": "Teresópolis", "points": 22},
	"res://images/cards/card (73).png": {"from": "Vassouras", "to": "Itaboraí", "points": 22}, ### 6
	"res://images/cards/card (74).png": {"from": "Piraí", "to": "Guapimirim", "points": 22},
	"res://images/cards/card (75).png": {"from": "Valença", "to": "Niterói", "points": 22},
	"res://images/cards/card (76).png": {"from": "Itaguaí", "to": "Valença", "points": 14},
	"res://images/cards/card (77).png": {"from": "Seropédica", "to": "Petrópolis", "points": 15},
	"res://images/cards/card (78).png": {"from": "Queimados", "to": "Itaboraí", "points": 16},
	"res://images/cards/card (79).png": {"from": "Volta Redonda", "to": "Miguel Pereira", "points": 16},
	"res://images/cards/card (80).png": {"from": "Nova Iguaçu", "to": "Tanguá", "points": 17},
	"res://images/cards/card (81).png": {"from": "Vassouras", "to": "Teresópolis", "points": 17},
	"res://images/cards/card (82).png": {"from": "Barra de Piraí", "to": "Niterói", "points": 17},
	"res://images/cards/card (83).png": {"from": "Japeri", "to": "Guapimirim", "points": 17},
	"res://images/cards/card (84).png": {"from": "Barra Mansa", "to": "Seropédica", "points": 11},
	"res://images/cards/card (85).png": {"from": "Piraí", "to": "Miguel Pereira", "points": 11},
	"res://images/cards/card (86).png": {"from": "Valença", "to": "Queimados", "points": 12},
	"res://images/cards/card (87).png": {"from": "Volta Redonda", "to": "Itaguaí", "points": 12},
	"res://images/cards/card (88).png": {"from": "Rio de Janeiro", "to": "Guapimirim", "points": 13},
	"res://images/cards/card (89).png": {"from": "Duque de Caxias", "to": "Teresópolis", "points": 13},
	"res://images/cards/card (90).png": {"from": "Barra Mansa", "to": "Vassouras", "points": 13},
	"res://images/cards/card (91).png": {"from": "Nova Iguaçu", "to": "Maricá", "points": 14},
	"res://images/cards/card (92).png": {"from": "Piraí", "to": "Barra de Piraí", "points": 8}, ### 7
	"res://images/cards/card (93).png": {"from": "Piraí", "to": "Nova iguaçu", "points": 9},
	"res://images/cards/card (94).png": {"from": "Barra de Piraí", "to": "Itaguaí", "points": 9}, ### 8
	"res://images/cards/card (95).png": {"from": "Volta Redonda", "to": "Paracambi", "points": 9},
	"res://images/cards/card (96).png": {"from": "Queimados", "to": "Niterói", "points": 10},
	"res://images/cards/card (97).png": {"from": "Guapamirim", "to": "Maricá", "points": 10},
	"res://images/cards/card (98).png": {"from": "Duque de Caxias", "to": "Itaboraí", "points": 11},
	"res://images/cards/card (99).png": {"from": "Teresópolis", "to": "Tanguá", "points": 11},
	"res://images/cards/card (100).png": {"from": "Duque de Caxias", "to": "Niterói", "points": 5},
	"res://images/cards/card (101).png": {"from": "Piraí", "to": "Seropédica", "points": 5},
	"res://images/cards/card (102).png": {"from": "Barra do Piraí", "to": "Valença", "points": 6}, ### 9
	"res://images/cards/card (103).png": {"from": "Niterói", "to": "Itaboraí", "points": 6}, ### 10
	"res://images/cards/card (104).png": {"from": "Vassouras", "to": "Japeri", "points": 6},
	"res://images/cards/card (105).png": {"from": "Itaguaí", "to": "Nova Iguaçu", "points": 7}, ### 11
	"res://images/cards/card (106).png": {"from": "Barra do Piraí", "to": "Queimados", "points": 7} ### 12
}
@onready var turn_manager = get_node("/root/TutorialTest/TurnManager")

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
		{"from": "Volta Redonda", "to": "Pinheiral", "color": "pink", "cost": 2},
		{"from": "Pinheiral", "to": "Barra do Piraí", "color": "blue", "cost": 4},
		{"from": "Pinheiral", "to": "Piraí", "color": "gray", "cost": 3},
		{"from": "Piraí", "to": "Seropédica", "color": "gray", "cost": 5},
		{"from": "Piraí", "to": "Paracambi", "color": "orange", "cost": 3},
		{"from": "Paracambi", "to": "Piraí", "color": "yellow", "cost": 3},
		{"from": "Seropédica", "to": "Itaguaí", "color": "green", "cost": 2},
		{"from": "Seropédica", "to": "Queimados", "color": "pink", "cost": 3},
		{"from": "Seropédica", "to": "Japeri", "color": "gray", "cost": 2},
		{"from": "Japeri", "to": "Paracambi", "color": "gray", "cost": 1},
		{"from": "Paracambi", "to": "Japeri", "color": "gray", "cost": 1},
		{"from": "Barra do Piraí", "to": "Paracambi", "color": "green", "cost": 4},
		{"from": "Barra do Piraí", "to": "Valença", "color": "gray", "cost": 6},
		{"from": "Barra do Piraí", "to": "Vassouras", "color": "pink", "cost": 4},
		{"from": "Valença", "to": "Vassouras", "color": "gray", "cost": 3},
		{"from": "Vassouras", "to": "Miguel Pereira", "color": "orange", "cost": 4},
		{"from": "Vassouras", "to": "Paracambi", "color": "white", "cost": 5},
		{"from": "Japeri", "to": "Queimados", "color": "green", "cost": 2},
		{"from": "Japeri", "to": "Miguel Pereira", "color": "gray", "cost": 6},
		{"from": "Queimados", "to": "Japeri", "color": "orange", "cost": 2},
		{"from": "Queimados", "to": "Nova Iguaçu", "color": "yellow", "cost": 2},
		{"from": "Nova Iguaçu", "to": "Queimados", "color": "white", "cost": 2},
		{"from": "Nova Iguaçu", "to": "Miguel Pereira", "color": "gray", "cost": 8},
		{"from": "Miguel Pereira", "to": "Petrópolis", "color": "gray", "cost": 7},
		{"from": "Petrópolis", "to": "Miguel Pereira", "color": "gray", "cost": 7},
		{"from": "Itaguaí", "to": "Nova Iguaçu", "color": "blue", "cost": 8},
		{"from": "Nova Iguaçu", "to": "Duque de Caxias", "color": "green", "cost": 3},
		{"from": "Duque de Caxias", "to": "Nova Iguaçu", "color": "orange", "cost": 3},
		{"from": "Duque de Caxias", "to": "Rio de Janeiro", "color": "white", "cost": 4},
		{"from": "Duque de Caxias", "to": "Petrópolis", "color": "yellow", "cost": 8},
		{"from": "Rio de Janeiro", "to": "Duque de Caxias", "color": "pink", "cost": 4},
		{"from": "Rio de Janeiro", "to": "Niterói", "color": "gray", "cost": 1},
		{"from": "Niterói", "to": "Rio de Janeiro", "color": "gray", "cost": 1},
		{"from": "Petrópolis", "to": "Guapimirim", "color": "white", "cost": 4},
		{"from": "Guapimirim", "to": "Itaboraí", "color": "orange", "cost": 6},
		{"from": "Itaboraí", "to": "Maricá", "color": "pink", "cost": 4},
		{"from": "Itaboraí", "to": "Tanguá", "color": "blue", "cost": 3},
		{"from": "Tanguá", "to": "Maricá", "color": "yellow", "cost": 5},
		{"from": "Niterói", "to": "Itaboraí", "color": "white", "cost": 6},
		{"from": "Niterói", "to": "Maricá", "color": "blue", "cost": 6},
		{"from": "Teresópolis", "to": "Petrópolis", "color": "green", "cost": 5},
		{"from": "Teresópolis", "to": "Guapimirim", "color": "pink", "cost": 2}
	]
}

func _ready():
	# Inicializa o dicionário de rotas para cada jogador
	for i in range(Global.num_players):
		player_claimed_routes[i] = []
	for i in range(5 - Global.num_players):
		player_claimed_routes["ia_" + str(i)] = []

	draw_map()
	print('draw')

func _generate_route_key(route_data: Dictionary) -> String:
	var city_names = [route_data.from, route_data.to]
	city_names.sort() # Ordena para garantir consistência (ex: A-B é o mesmo que B-A)
	return city_names[0] + "-" + city_names[1] + "-" + route_data.color

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
			
			var route_key = _generate_route_key(route_data)
			route_nodes[route_key] = route_instance
	
			# Configura a rota usando a função setup_route
			route_instance.setup_route(from_city_node, to_city_node, parse_color(route_data.color), route_data.cost, route_data.color)
			route_instance.from_city_name = from_city_name # Para depuração
			route_instance.to_city_name = to_city_name   # Para depuração

			# Conecta o sinal 'route_clicked' da rota
			route_instance.route_clicked.connect(_on_route_clicked)
			route_instance.z_index = 1
		else:
			push_error("Erro: Cidade não encontrada para rota: ", from_city_name, " ou ", to_city_name)

# Função auxiliar para converter string de cor para objeto Color
func parse_color(color_string: String) -> Color:
	const ALPHA_VALUE: float = 0.6

	match color_string.to_lower():
		"red": return Color(Color.RED.r, Color.RED.g, Color.RED.b, ALPHA_VALUE)
		"blue": return Color(Color.BLUE.r, Color.BLUE.g, Color.BLUE.b, ALPHA_VALUE)
		"green": return Color(Color.GREEN.r, Color.GREEN.g, Color.GREEN.b, ALPHA_VALUE)
		"yellow": return Color(Color.YELLOW.r, Color.YELLOW.g, Color.YELLOW.b, ALPHA_VALUE)
		"orange": return Color(Color.ORANGE_RED, ALPHA_VALUE) # Laranja
		"purple": return Color(Color.MEDIUM_PURPLE, ALPHA_VALUE) # Roxo
		"black": return Color(Color.BLACK.r, Color.BLACK.g, Color.BLACK.b, ALPHA_VALUE)
		"white": return Color(Color.WHITE.r, Color.WHITE.g, Color.WHITE.b, ALPHA_VALUE)
		"gray": return Color(Color.GRAY.r, Color.GRAY.g, Color.GRAY.b, ALPHA_VALUE)
		"pink": return Color(Color.DEEP_PINK, ALPHA_VALUE) # Rosa
		_: return Color(Color.WHITE.r, Color.WHITE.g, Color.WHITE.b, ALPHA_VALUE)  # Padrão para branco se a cor não for reconhecida

func color_name_to_card_key(color_string: String) -> String:
	match color_string.to_lower():
		"blue":
			return "blueTrain"
		"green":
			return "greenTrain"
		"yellow":
			return "yellowTrain"
		"orange":
			return "orangeTrain"
		"pink":
			return "pinkTrain"
		"red":
			return "redTrain"
		"white":
			return "rainbowTrain"
		"gray":
			return "grayTrain"
		_:
			return "grayTrain"

func attempt_buy_route(index_player: int, card_key: String, cost: int) -> bool:
	if player_hand[index_player] == null:
		return false
	var rainbow_count = player_hand[index_player].player_hand["rainbowTrain"]["count"] if "rainbowTrain" in player_hand[index_player].player_hand else 0
	if card_key == "grayTrain":
		var best_color = ""
		var best_count = 0
		for key in player_hand[index_player].player_hand.keys():
			if key == "rainbowTrain":
				continue
			var c = player_hand[index_player].player_hand[key]["count"]
			if c > best_count:
				best_count = c
				best_color = key
		if best_color == "":
			best_color = "grayTrain"
		if best_count + rainbow_count < cost:
			return false
		var use_from_color = min(cost, best_count)
		for i in range(use_from_color):
			player_hand[index_player].remove_card_from_hand(best_color)
		var remaining = cost - use_from_color
		for i in range(remaining):
			player_hand[index_player].remove_card_from_hand("rainbowTrain")
		return true
	else:
		var color_count = player_hand[index_player].player_hand[card_key]["count"] if card_key in player_hand[index_player].player_hand else 0
		if color_count + rainbow_count < cost:
			return false
		var use_from_color = min(cost, color_count)
		for i in range(use_from_color):
			player_hand[index_player].remove_card_from_hand(card_key)
		var remaining = cost - use_from_color
		for i in range(remaining):
			player_hand[index_player].remove_card_from_hand("rainbowTrain")
		return true

func is_objective_complete(player_index: int, city_start: String, city_end: String, required_points: int) -> bool:
	if not player_claimed_routes.has(player_index) or player_claimed_routes[player_index].is_empty():
		return false

	# 1. Construir um grafo de adjacência com custos para as rotas do jogador
	var adjacency_list = {}
	for route in player_claimed_routes[player_index]:
		var city_a = route["from"]
		var city_b = route["to"]
		var cost = route["cost"]
		if not adjacency_list.has(city_a): adjacency_list[city_a] = []
		if not adjacency_list.has(city_b): adjacency_list[city_b] = []
		adjacency_list[city_a].append({"neighbor": city_b, "cost": cost})
		adjacency_list[city_b].append({"neighbor": city_a, "cost": cost})

	if not adjacency_list.has(city_start):
		return false # Cidade de início não tem rotas compradas pelo jogador

	# 2. Iniciar a busca recursiva a partir da cidade inicial
	var visited_path: Array = [] # Usado para evitar ciclos (ex: A->B->A)
	return _find_path_with_cost_recursive(city_start, city_end, required_points, visited_path, 0, adjacency_list)

# Isso é diferente de 'is_objective_complete', pois opera no mapa inteiro para a IA poder acessar.
func find_shortest_path_routes(city_start: String, city_end: String) -> Array:
	# 1. Construir um grafo de adjacência de TODO o mapa
	var adjacency_list = {}
	for route in map_data.routes:
		var city_a = route.from
		var city_b = route.to
		if not adjacency_list.has(city_a): adjacency_list[city_a] = []
		if not adjacency_list.has(city_b): adjacency_list[city_b] = []
		adjacency_list[city_a].append(city_b)
		adjacency_list[city_b].append(city_a)

	# 2. Algoritmo BFS para encontrar o caminho mais curto
	var queue: Array = [[city_start]] # A fila agora guarda caminhos
	var visited: Array = [city_start]

	while not queue.is_empty():
		var path = queue.pop_front()
		var current_city = path.back()

		if current_city == city_end:
			# Caminho encontrado, agora converta-o em uma lista de rotas
			var path_routes = []
			for i in range(path.size() - 1):
				var from_c = path[i]
				var to_c = path[i+1]
				# Encontra o dicionário de rota correspondente
				for r_data in map_data.routes:
					if (r_data.from == from_c and r_data.to == to_c) or (r_data.from == to_c and r_data.to == from_c):
						path_routes.append(r_data)
						break
			return path_routes

		if adjacency_list.has(current_city):
			for neighbor in adjacency_list[current_city]:
				if not neighbor in visited:
					visited.append(neighbor)
					var new_path = path.duplicate()
					new_path.append(neighbor)
					queue.append(new_path)
	
	return [] # Retorna array vazio se não encontrar caminho

# Permite que a IA encontre o nó de uma rota usando os dados dela
func get_route_node_by_data(route_data: Dictionary) -> Node:
	var route_key = _generate_route_key(route_data)
	return route_nodes.get(route_key, null)

# Função simplificada para o TurnManager chamar após o pagamento ser processado
func claim_route_for_player(route_node, player_id):
	if route_node and not route_node.claimed:
		route_node.claimed = true
		
		# LÓGICA DE COR MUITO MAIS SIMPLES
		var player_color_val = Global.get_participant_color(player_id)
		route_node.set_wagons_route_color(player_color_val)
		
		var route_info = {
			"from": route_node.from_city_name,
			"to": route_node.to_city_name,
			"cost": route_node.wagon_cost
		}
		if not player_claimed_routes.has(player_id):
			player_claimed_routes[player_id] = []
		player_claimed_routes[player_id].append(route_info)

		route_claimed.emit(player_id)

# Função auxiliar recursiva que faz a busca em profundidade (DFS)
func _find_path_with_cost_recursive(current_city: String, end_city: String, required_points: int, visited_path: Array, current_cost: int, adjacency_list: Dictionary) -> bool:
	
	# Adiciona a cidade atual ao caminho para evitar visitar ela mesma no mesmo galho
	visited_path.push_back(current_city)

	# Condição de sucesso: Chegamos ao destino
	if current_city == end_city:
		# Verificamos se o custo do caminho encontrado é igual ao custo do objetivo
		if current_cost == required_points:
			return true # Sucesso! Encontramos um caminho com o custo exato.

	# Condição de poda: Se o custo atual já excedeu o necessário, não continue por este caminho
	if current_cost > required_points:
		visited_path.pop_back() # Remove a cidade atual do caminho para "voltar" na recursão
		return false

	# Explora os vizinhos
	if adjacency_list.has(current_city):
		for edge in adjacency_list[current_city]:
			var neighbor = edge["neighbor"]
			var cost_to_neighbor = edge["cost"]

			# Se ainda não visitamos o vizinho neste caminho específico
			if not neighbor in visited_path:
				# Chama a função para o vizinho, somando o custo
				if _find_path_with_cost_recursive(neighbor, end_city, required_points, visited_path, current_cost + cost_to_neighbor, adjacency_list):
					return true # Um caminho válido foi encontrado em um galho da recursão, propaga o sucesso

	# Backtracking: Remove a cidade atual do caminho para que outros galhos da busca possam usá-la
	visited_path.pop_back()
	
	return false # Nenhum caminho com o custo exato foi encontrado a partir desta cidade

func show_info_popup(message: String, global_position: Vector2):
	var popup_instance = info_popup_scene.instantiate()
	add_child(popup_instance) # Adiciona o pop-up como filho do Map (ou de uma camada UI)

	var popup_offset = Vector2(get_window().size.x - 300, 200) # Para centralizar o pop-up
	popup_instance.show_message(message,  popup_offset)

# Funções de callback para os sinais de clique
func _on_city_clicked(city_node: Node2D):
	print("Mapa recebeu clique na cidade: ", city_node.city_name)
	show_info_popup("Cidade Clicada: " + city_node.city_name, city_node.position)
	# Lógica do jogo aqui (ex: destacar cidade para construir rota)

func _on_route_clicked(route_node: Node2D):
	if route_node.claimed:
		show_info_popup("Rota já comprada", route_node.position)
		return

	var player_index = turn_manager.index_player
	var card_key = color_name_to_card_key(route_node.route_color_name)
	
	if attempt_buy_route(player_index, card_key, route_node.wagon_cost):
		var color = Global.get_participant_color(player_index)
		#route_node.set_wagons_route_color(route_node.route_color_name)
		route_node.set_wagons_route_color(color)

		route_node.claimed = true
		
		var route_info = {"from": route_node.from_city_name, "to": route_node.to_city_name, "cost": route_node.wagon_cost}
		if not player_claimed_routes.has(player_index):
			player_claimed_routes[player_index] = []
		player_claimed_routes[player_index].append(route_info)
		
		show_info_popup("Rota comprada!", route_node.position)
		print("Rota comprada! por jogador: ", player_index)
		route_claimed.emit(player_index)
	else:
		show_info_popup("Cartas insuficientes", route_node.position)
