extends Control

@onready var borda_2d: Sprite2D = $Borda
@onready var sprite_2d: Sprite2D = $Sprite2D 
@onready var area_2d: Area2D = $Area2D

var original_position_x: float
@export var hover_offset_x: float = 10.0
@export var tween_duration: float = 0.2

var current_tween: Tween
signal cliquei
@onready var carta_clicada

func _ready():
	if borda_2d.material:
		borda_2d.material = borda_2d.material.duplicate()
	original_position_x = position.x
	area_2d.input_pickable = true
	area_2d.mouse_entered.connect(_on_mouse_entered)
	area_2d.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	var target_x = original_position_x - hover_offset_x
	start_tween_x(target_x)

func _on_mouse_exited():
	var target_x = original_position_x
	start_tween_x(target_x)
	
func start_tween_x(target_x_pos: float):
	if current_tween and current_tween.is_valid():
		current_tween.kill()

	current_tween = create_tween()

	current_tween.tween_property(self, "position:x", target_x_pos, tween_duration)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return # Ignora qualquer evento que não seja um clique esquerdo
	carta_clicada = sprite_2d.texture.resource_path.get_file().get_basename()
	print(carta_clicada)
	emit_signal("cliquei")
