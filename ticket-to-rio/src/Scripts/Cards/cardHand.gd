extends Node2D

@onready var area_2d: Area2D = $Area2D

var original_position_y: float
@export var hover_offset_x: float = 10.0
@export var tween_duration: float = 0.3

var current_tween: Tween

func _ready():
	original_position_y = position.y
	area_2d.input_pickable = true
	area_2d.mouse_entered.connect(_on_mouse_entered)
	area_2d.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	var target_y = original_position_y - hover_offset_x
	start_tween_x(target_y)

func _on_mouse_exited():
	var target_x = original_position_y
	start_tween_x(target_x)
	
func start_tween_x(target_x_pos: float):

	if current_tween and current_tween.is_valid():
		current_tween.kill()

	current_tween = create_tween()

	current_tween.tween_property(self, "position:y", target_x_pos, tween_duration)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
