extends Control


func _on_facil_pressed() -> void:
	Global.difficult = 0
	get_tree().change_scene_to_file("res://src/Scenes/tutorialTest.tscn")

func _on_dificil_pressed() -> void:
	Global.difficult = 2
	get_tree().change_scene_to_file("res://src/Scenes/tutorialTest.tscn")
