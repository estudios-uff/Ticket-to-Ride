extends Control

func _on_jogar_pressed(num_players) -> void:
	Global.num_players = num_players
	Global.assign_player_colors(num_players)
	get_tree().change_scene_to_file("res://src/Scenes/tutorialTest.tscn")
