extends Node

var num_players: int

var player_colors: Dictionary = {}

const AVAILABLE_COLORS := {
	"red": Color.RED,
	"blue": Color.BLUE,
	"green": Color.GREEN,
	"yellow": Color.YELLOW,
	"orange": Color.ORANGE_RED,
	"pink": Color.DEEP_PINK,
	"black": Color.BLACK,
	"white": Color.WHITE
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
