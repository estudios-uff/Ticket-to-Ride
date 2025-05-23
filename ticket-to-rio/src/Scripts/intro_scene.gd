extends Control

@onready var animation_intro = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_intro.play("fade_in")
	get_tree().create_timer(3).timeout.connect(black_out)


func black_out():
	animation_intro.play("fade_out")
	get_tree().create_timer(2).timeout.connect(start_scene)
	
func start_scene():
	get_tree().change_scene_to_file("res://src/Scenes/main_menu.tscn")
