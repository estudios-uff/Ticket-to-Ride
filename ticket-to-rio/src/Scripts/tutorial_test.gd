extends Node2D
var num_players: int

func  _ready() -> void:
	num_players = Global.num_players

func _process(delta: float) -> void:
	print("Numero de players: ", num_players)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/main_menu.tscn")

func _on_test_cards_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Cards/cards.tscn")
