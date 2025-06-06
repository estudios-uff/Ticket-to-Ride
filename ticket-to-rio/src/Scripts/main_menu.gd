extends Control

var game = load("res://src/Scenes/tutorialTest.tscn")

func _ready() -> void:
	$VideoStreamPlayer.play()

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/selecionar_jogadores.tscn")


func _on_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/opcoes.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_regras_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/regras.tscn")


func _on_creditos_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/Credits.tscn")
