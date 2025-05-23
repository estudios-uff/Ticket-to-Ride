extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/main_menu.tscn")

func _on_card_button_pressed(site) -> void:
	OS.shell_open(site)
