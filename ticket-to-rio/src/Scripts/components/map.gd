extends Node2D

# Preload das cenas das subcenas
var city_scene: PackedScene = preload("res://src/Scenes/TestMap/City.tscn")
var route_scene: PackedScene = preload("res://src/Scenes/TestMap/Route.tscn")
var info_popup_scene: PackedScene = preload("res://src/Scenes/TestMap/InfoPopup.tscn")
var cities: Dictionary = {} # Armazenará as instâncias das cidades (nome: nó_da_cidade)

@export var player_hand_path: NodePath
@export var player_color: Color = Color.GREEN
var player_hand: Node = null

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
		{"from": "Pinheiral", "to": "Piraí", "color": "grey", "cost": 3},
		{"from": "Piraí", "to": "Seropédica", "color": "grey", "cost": 5},
		{"from": "Piraí", "to": "Paracambi", "color": "orange", "cost": 3},
		{"from": "Paracambi", "to": "Piraí", "color": "yellow", "cost": 3},
		{"from": "Seropédica", "to": "Itaguaí", "color": "green", "cost": 2},
		{"from": "Seropédica", "to": "Queimados", "color": "pink", "cost": 3},
		{"from": "Seropédica", "to": "Japeri", "color": "grey", "cost": 2},
		{"from": "Japeri", "to": "Paracambi", "color": "grey", "cost": 1},
		{"from": "Paracambi", "to": "Japeri", "color": "grey", "cost": 1},
		{"from": "Barra do Piraí", "to": "Paracambi", "color": "green", "cost": 4},
		{"from": "Barra do Piraí", "to": "Valença", "color": "grey", "cost": 6},
		{"from": "Barra do Piraí", "to": "Vassouras", "color": "pink", "cost": 4},
		{"from": "Valença", "to": "Vassouras", "color": "grey", "cost": 3},
		{"from": "Vassouras", "to": "Miguel Pereira", "color": "orange", "cost": 4},
		{"from": "Vassouras", "to": "Paracambi", "color": "white", "cost": 5},
		{"from": "Japeri", "to": "Queimados", "color": "green", "cost": 2},
		{"from": "Japeri", "to": "Miguel Pereira", "color": "grey", "cost": 6},
		{"from": "Queimados", "to": "Japeri", "color": "orange", "cost": 2},
		{"from": "Queimados", "to": "Nova Iguaçu", "color": "yellow", "cost": 2},
		{"from": "Nova Iguaçu", "to": "Queimados", "color": "white", "cost": 2},
		{"from": "Nova Iguaçu", "to": "Miguel Pereira", "color": "grey", "cost": 8},
		{"from": "Miguel Pereira", "to": "Petrópolis", "color": "grey", "cost": 7},
		{"from": "Petrópolis", "to": "Miguel Pereira", "color": "grey", "cost": 7},
		{"from": "Itaguaí", "to": "Nova Iguaçu", "color": "blue", "cost": 8},
		{"from": "Nova Iguaçu", "to": "Duque de Caxias", "color": "green", "cost": 3},
		{"from": "Duque de Caxias", "to": "Nova Iguaçu", "color": "orange", "cost": 3},
		{"from": "Duque de Caxias", "to": "Rio de Janeiro", "color": "white", "cost": 4},
		{"from": "Duque de Caxias", "to": "Petrópolis", "color": "yellow", "cost": 8},
		{"from": "Rio de Janeiro", "to": "Duque de Caxias", "color": "pink", "cost": 4},
		{"from": "Rio de Janeiro", "to": "Niterói", "color": "grey", "cost": 1},
		{"from": "Niterói", "to": "Rio de Janeiro", "color": "grey", "cost": 1},
		{"from": "Petrópolis", "to": "Guapimirim", "color": "white", "cost": 4},
		{"from": "Guapimirim", "to": "Itaboraí", "color": "orange", "cost": 6},
		{"from": "Itaboraí", "to": "Maricá", "color": "pink", "cost": 4},
		{"from": "Itaboraí", "to": "Tanguá", "color": "blue", "cost": 3},
		{"from": "Tanguá", "to": "Maricá", "color": "yellow", "cost": 5},
		{"from": "Niterói", "to": "Itaboraí", "color": "white", "cost": 6},
		{"from": "Niterói", "to": "Maricá", "color": "blue", "cost": 6},
		{"from": "Teresópolis", "to": "Petrópolis", "color": "green", "cost": 5},
		{"from": "Teresópolis", "to": "Guapimirim", "color": "pink", "cost": 2},
		
	]
}

func _ready():
        if player_hand_path:
                player_hand = get_node_or_null(player_hand_path)
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
                "gray", "grey":
                        return "grayTrain"
                _:
                        return "grayTrain"

func attempt_buy_route(card_key: String, cost: int) -> bool:
        if player_hand == null:
                return false
        var rainbow_count = player_hand.player_hand["rainbowTrain"]["count"] if "rainbowTrain" in player_hand.player_hand else 0
        if card_key == "grayTrain":
                var best_color = ""
                var best_count = 0
                for key in player_hand.player_hand.keys():
                        if key == "rainbowTrain":
                                continue
                        var c = player_hand.player_hand[key]["count"]
                        if c > best_count:
                                best_count = c
                                best_color = key
                if best_color == "":
                        best_color = "grayTrain"
                if best_count + rainbow_count < cost:
                        return false
                var use_from_color = min(cost, best_count)
                for i in range(use_from_color):
                        player_hand.remove_card_from_hand(best_color)
                var remaining = cost - use_from_color
                for i in range(remaining):
                        player_hand.remove_card_from_hand("rainbowTrain")
                return true
        else:
                var color_count = player_hand.player_hand[card_key]["count"] if card_key in player_hand.player_hand else 0
                if color_count + rainbow_count < cost:
                        return false
                var use_from_color = min(cost, color_count)
                for i in range(use_from_color):
                        player_hand.remove_card_from_hand(card_key)
                var remaining = cost - use_from_color
                for i in range(remaining):
                        player_hand.remove_card_from_hand("rainbowTrain")
                return true



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
        if route_node.claimed:
                show_info_popup("Rota já comprada", route_node.position)
                return

        var card_key = color_name_to_card_key(route_node.route_color_name)
        if attempt_buy_route(card_key, route_node.wagon_cost):
                route_node.set_wagons_player_color(player_color)
                route_node.claimed = true
                show_info_popup("Rota comprada!", route_node.position)
        else:
                show_info_popup("Cartas insuficientes", route_node.position)
