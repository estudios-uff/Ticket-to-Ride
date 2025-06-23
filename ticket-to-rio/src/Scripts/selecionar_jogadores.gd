extends Control

func _on_jogar_pressed(num_players) -> void:
	Global.num_players = num_players
	if num_players<5:
		get_tree().change_scene_to_file("res://src/Scenes/difficultyIA.tscn")
	else:
		get_tree().change_scene_to_file("res://src/Scenes/tutorialTest.tscn")
