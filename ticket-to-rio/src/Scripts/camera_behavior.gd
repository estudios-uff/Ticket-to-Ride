extends Node

@onready var camera: Camera2D = $"../../Camera2D"
@onready var objeto_pai: Node = $".."

var aparenciaConstante

@export var objeto_pai_width: float
@export var objeto_pai_height: float

enum ScreenAnchor {
	TOP_LEFT, TOP_CENTER, TOP_RIGHT,
	CENTER_LEFT, CENTER, CENTER_RIGHT,
	BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT
}

@export var anchoramento: ScreenAnchor = ScreenAnchor.TOP_RIGHT:
	set(value):
		anchoramento = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.ajustezoom.connect(_ajustaEscala)
	aparenciaConstante = objeto_pai.scale * camera.zoom
	change_object_position(anchoramento)


func _ajustaEscala():
	objeto_pai.scale = aparenciaConstante / camera.zoom
	change_object_position(anchoramento)

func change_object_position(screen_anchor_point) -> void:
	var viewport_rect_pixels: Rect2 = get_viewport().get_visible_rect()
	var viewport_px_size: Vector2 = viewport_rect_pixels.size
	var screen_center_world: Vector2 = camera.get_screen_center_position()
	var half_world_view_extents: Vector2 = (viewport_px_size / 2.0) / camera.zoom
	var screen_anchor_world_pos: Vector2
	match screen_anchor_point:
		ScreenAnchor.TOP_LEFT:
			screen_anchor_world_pos = screen_center_world + Vector2(-half_world_view_extents.x, -half_world_view_extents.y)
		ScreenAnchor.TOP_CENTER:
			screen_anchor_world_pos = screen_center_world + Vector2(0, -half_world_view_extents.y)
		ScreenAnchor.TOP_RIGHT:
			screen_anchor_world_pos = screen_center_world + Vector2(half_world_view_extents.x, -half_world_view_extents.y)
		ScreenAnchor.CENTER_LEFT:
			screen_anchor_world_pos = screen_center_world + Vector2(-half_world_view_extents.x, 0)
		ScreenAnchor.CENTER:
			screen_anchor_world_pos = screen_center_world
		ScreenAnchor.CENTER_RIGHT:
			screen_anchor_world_pos = screen_center_world + Vector2(half_world_view_extents.x, 0)
		ScreenAnchor.BOTTOM_LEFT:
			screen_anchor_world_pos = screen_center_world + Vector2(-half_world_view_extents.x, half_world_view_extents.y)
		ScreenAnchor.BOTTOM_CENTER:
			screen_anchor_world_pos = screen_center_world + Vector2(0, half_world_view_extents.y)
		ScreenAnchor.BOTTOM_RIGHT:
			screen_anchor_world_pos = screen_center_world + Vector2(half_world_view_extents.x, half_world_view_extents.y)
	var current_deck_width_world: float = objeto_pai_width * objeto_pai.scale.x
	var current_deck_height_world: float = objeto_pai_height * objeto_pai.scale.y
	var new_deck_global_pos = Vector2(screen_anchor_world_pos.x - current_deck_width_world/1.75, screen_anchor_world_pos.y + current_deck_height_world/1.5)
	objeto_pai.global_position = new_deck_global_pos
