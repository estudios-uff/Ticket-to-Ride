extends Node2D

@export var from_city_name: String = ""
@export var to_city_name: String = ""
@export var route_color: Color = Color.WHITE
@export var wagon_cost: int = 0

@onready var line_2d: Line2D = $Line2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

var wagon_sprite_scene: PackedScene = preload("res://src/Scenes/TestMap/WagonSprite.tscn")
var from_city_node: Node2D = null
var to_city_node: Node2D = null

signal route_clicked(route_node)

func _ready():
	if area_2d:
		area_2d.input_event.connect(_on_area_2d_input_event)

# Função para configurar a rota dinamicamente
func setup_route(p_from_city: Node2D, p_to_city: Node2D, p_color: Color, p_cost: int):
	from_city_node = p_from_city
	to_city_node = p_to_city
	route_color = p_color
	wagon_cost = p_cost

	# Define os pontos da Line2D
	line_2d.clear_points()
	line_2d.add_point(from_city_node.position)
	line_2d.add_point(to_city_node.position)
	line_2d.default_color = route_color
	line_2d.width = 5
	line_2d.queue_redraw()

	# Configura o CollisionShape2D para cobrir a rota
	# Criamos um retângulo que se estende ao longo da rota
	var start_pos = from_city_node.position
	var end_pos = to_city_node.position

	var direction = (end_pos - start_pos).normalized()
	var length = start_pos.distance_to(end_pos)
	var width = 15.0 # Largura da área de colisão (ajuste conforme necessário)

	# Crie um RectangleShape2D e defina seu tamanho e posição
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(length, width)
	collision_shape_2d.shape = rect_shape

	# Posicione o CollisionShape2D no centro da linha
	collision_shape_2d.position = (start_pos + end_pos) / 2 - global_position # Ajuste para posição local
	collision_shape_2d.rotation = direction.angle() # Rotaciona para alinhar com a rota

	# Instanciar sprites de vagões
	spawn_wagons()

func spawn_wagons():
	# Remover vagões existentes antes de adicionar novos
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("Wagon"):
			child.queue_free()

	if wagon_cost == 0: return # Não spawnar vagões se o custo for 0

	var start_pos = from_city_node.position
	var end_pos = to_city_node.position

	var direction = (end_pos - start_pos).normalized()
	var length = start_pos.distance_to(end_pos)

	# Ajuste o espaçamento entre os vagões
	# Uma forma simples: dividir o comprimento pelo número de vagões + 1 para um bom espaçamento
	var spacing_factor = 1.0 / (wagon_cost + 1)
	var current_pos_offset = 0.0

	for i in range(wagon_cost):
		var wagon_instance = wagon_sprite_scene.instantiate()
		add_child(wagon_instance) # Adicione como filho da rota

		# Calcule a posição do vagão ao longo da rota
		current_pos_offset = (i + 1) * spacing_factor
		wagon_instance.position = start_pos.lerp(end_pos, current_pos_offset) - global_position # Ajuste para posição local

		# Rotacionar o vagão para alinhar com a rota
		wagon_instance.rotation = direction.angle()
		wagon_instance.name = "Wagon" + str(i) # Nome para fácil identificação

		# Mudar a cor do vagão (se aplicável, por exemplo, para vagões do jogador)
		# wagon_instance.modulate = route_color # Se você quiser que o sprite pegue a cor da rota

	

# Função para mudar os sprites dos vagões para uma cor específica (ex: do jogador)
func set_wagons_player_color(player_color: Color):
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("Wagon"):
			child.modulate = player_color
			# Você pode carregar um sprite diferente aqui se tiver sprites específicos para jogadores
			# child.texture = load("res://assets/player_wagon_sprite.png")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Rota Clicada: ", from_city_name, " - ", to_city_name)
			emit_signal("route_clicked", self) # Emite o sinal com a própria rota como argumento
