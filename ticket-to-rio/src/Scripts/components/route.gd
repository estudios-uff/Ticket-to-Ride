extends Node2D
class_name Route

@export var from_city_name: String = ""
@export var to_city_name: String = ""
@export var route_color: Color = Color.WHITE
@export var wagon_cost: int = 0
@export var parallel_offset: float = 5.5
@export var line_visual_width: float = 10.0
@onready var line_2d: Line2D = $Line2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@export var collision_area_width: float = 15.0

var wagon_sprite_scene: PackedScene = preload("res://src/Scenes/TestMap/WagonSprite.tscn")
var from_city_node: Node2D = null
var to_city_node: Node2D = null

signal route_clicked(route_node)

func _ready():
	if area_2d:
		area_2d.input_event.connect(_on_area_2d_input_event)
		
func setup_route(p_from_city: Node2D, p_to_city: Node2D, p_color: Color, p_cost: int):
	from_city_node = p_from_city
	to_city_node = p_to_city
	route_color = p_color
	wagon_cost = p_cost

	if not is_instance_valid(from_city_node) or not is_instance_valid(to_city_node):
		printerr("Route setup: From or To city node is not valid.")
		line_2d.clear_points() 
		line_2d.queue_redraw()
		_clear_wagons() 
		return

	var start_pos_global = from_city_node.global_position
	var end_pos_global = to_city_node.global_position

	var direction = (end_pos_global - start_pos_global).normalized()
	var perpendicular_offset_vec = Vector2.ZERO
	if parallel_offset != 0.0:
		var perpendicular_direction = direction.orthogonal()
		perpendicular_offset_vec = perpendicular_direction * parallel_offset

	var actual_start_pos_global = start_pos_global + perpendicular_offset_vec
	var actual_end_pos_global = end_pos_global + perpendicular_offset_vec

	
	line_2d.clear_points()
	line_2d.add_point(to_local(actual_start_pos_global))
	line_2d.add_point(to_local(actual_end_pos_global))
	line_2d.default_color = route_color
	line_2d.width = line_visual_width
	line_2d.queue_redraw()

	
	var route_length = start_pos_global.distance_to(end_pos_global)

	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(route_length, collision_area_width)
	collision_shape_2d.shape = rect_shape

	var collision_center_global = (actual_start_pos_global + actual_end_pos_global) / 2
	
	collision_shape_2d.position = area_2d.to_local(collision_center_global)
	collision_shape_2d.rotation = direction.angle() 

	spawn_wagons()

func update_route_visuals():
	if not is_instance_valid(from_city_node) or not is_instance_valid(to_city_node):
		line_2d.clear_points()
		line_2d.queue_redraw()
		_clear_wagons()
		if is_instance_valid(collision_shape_2d) and is_instance_valid(collision_shape_2d.shape):
			
			
			pass
		return

	var start_pos_global = from_city_node.global_position
	var end_pos_global = to_city_node.global_position

	var direction = (end_pos_global - start_pos_global).normalized()
	var perpendicular_offset_vec = Vector2.ZERO
	if parallel_offset != 0.0:
		var perpendicular_direction = direction.orthogonal()
		perpendicular_offset_vec = perpendicular_direction * parallel_offset

	var actual_start_pos_global = start_pos_global + perpendicular_offset_vec
	var actual_end_pos_global = end_pos_global + perpendicular_offset_vec

	line_2d.clear_points()
	line_2d.add_point(to_local(actual_start_pos_global))
	line_2d.add_point(to_local(actual_end_pos_global))
	line_2d.queue_redraw()

	var route_length = start_pos_global.distance_to(end_pos_global)
	
	var rect_shape: RectangleShape2D
	if collision_shape_2d.shape is RectangleShape2D:
		rect_shape = collision_shape_2d.shape as RectangleShape2D
	else:
		rect_shape = RectangleShape2D.new()
		collision_shape_2d.shape = rect_shape
	
	rect_shape.size = Vector2(route_length, collision_area_width)

	var collision_center_global = (actual_start_pos_global + actual_end_pos_global) / 2
	collision_shape_2d.position = area_2d.to_local(collision_center_global)
	collision_shape_2d.rotation = direction.angle()

	spawn_wagons() 

func _clear_wagons():
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("Wagon"):
			child.queue_free()

func spawn_wagons():
	_clear_wagons() 

	if wagon_cost == 0: return
	if not is_instance_valid(from_city_node) or not is_instance_valid(to_city_node):
		return

	var start_pos_global = from_city_node.global_position
	var end_pos_global = to_city_node.global_position
	var direction = (end_pos_global - start_pos_global).normalized()

	var perpendicular_offset_vec = Vector2.ZERO
	if parallel_offset != 0.0:
		var perpendicular_direction = direction.orthogonal()
		perpendicular_offset_vec = perpendicular_direction * parallel_offset

	var actual_start_pos_global = start_pos_global + perpendicular_offset_vec
	var actual_end_pos_global = end_pos_global + perpendicular_offset_vec
	
	var spacing_factor = 1.0 / (wagon_cost + 1)

	for i in range(wagon_cost):
		var wagon_instance = wagon_sprite_scene.instantiate()
		add_child(wagon_instance) 

		var t = (i + 1) * spacing_factor
		var wagon_global_pos = actual_start_pos_global.lerp(actual_end_pos_global, t)
		
		wagon_instance.position = to_local(wagon_global_pos) 
		wagon_instance.rotation = direction.angle() 
		wagon_instance.name = "Wagon" + str(i)

		
		

func set_wagons_player_color(player_color: Color):
	for child in get_children():
		if child is Sprite2D and child.name.begins_with("Wagon"):
			child.modulate = player_color

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Route Clicked: ", from_city_name, " - ", to_city_name, " (Offset: ", parallel_offset, ")")
			emit_signal("route_clicked", self)
