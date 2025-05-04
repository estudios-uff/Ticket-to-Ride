extends Node2D



func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/main_menu.tscn")


func _on_test_cards_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Cards/cards.tscn")
