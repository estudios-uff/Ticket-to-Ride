extends Node

var num_players: int

var player_colors: Dictionary = {}

const AVAILABLE_COLORS := {
	"red": Color(1, 0, 0),
	"blue": Color(0, 0, 1),
	"green": Color(0, 1, 0),
	"yellow": Color(1, 1, 0),
	"orange": Color(1, 0.5, 0),
	"pink": Color(1, 0.75, 0.8),
	"black": Color(0, 0, 0),
	"white": Color(1, 1, 1)
}

func assign_player_colors(num: int) -> void:
	player_colors.clear()
	var names = AVAILABLE_COLORS.keys()
	for i in range(num):
		var name = names[i % names.size()]
		player_colors[i] = {"name": name, "color": AVAILABLE_COLORS[name]}

func get_player_color(player_id: int) -> Color:
	if player_colors.has(player_id):
		return player_colors[player_id]["color"]
	return Color.WHITE

func get_player_color_name(player_id: int) -> String:
	if player_colors.has(player_id):
		return player_colors[player_id]["name"]
	return "white"
