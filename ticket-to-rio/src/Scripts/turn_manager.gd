extends Node

var index_player = 1

func _on_end_turn_button_pressed() -> void:
	if index_player<Global.num_players:
		index_player += 1
		change_player_hand()
		return
		
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	if Global.num_players<5:
		# Fazer com que o jogador não possa interagir com suas cartas, com o deck ou com o board
		# lock_player()
		for i in range(5-Global.num_players):
			$"../EnemyThinking".start()
			await $"../EnemyThinking".timeout
			print("agindo...")
			opponents_ai_turn()
			$"../EnemyThinking".start()
			await $"../EnemyThinking".timeout
			print("passei!")
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
	if index_player == Global.num_players:
		index_player = 1
		change_player_hand()

func opponents_ai_turn():
	pass # Implementar compra de cartas e tomada de decisão da IA

func change_player_hand():
	pass # Mudar a instancia da mão para mostrar a mão do próximo jogador
