extends Node

var num_players: int

# O ÚNICO dicionário que vamos precisar para guardar os dados dos jogadores e IAs
var participants: Dictionary = {}

# Pool de cores disponíveis
const AVAILABLE_COLORS := {
	"blue": Color.SKY_BLUE,
	"green": Color.LIME_GREEN,
	"yellow": Color.YELLOW,
	"orange": Color.ORANGE_RED,
	"pink": Color.DEEP_PINK,
	"red": Color.RED,
	"gray": Color.GRAY,
	"white": Color.WHITE
}

# NOVA FUNÇÃO ÚNICA para atribuir cores a todos
func assign_participant_colors(p_num_players: int, num_ias: int):
	participants.clear()
	var color_keys = AVAILABLE_COLORS.keys()
	var color_index = 0

	# 1. Atribui para os jogadores humanos
	for i in range(p_num_players):
		if color_index < color_keys.size():
			var c_name = color_keys[color_index]
			var c_color = AVAILABLE_COLORS[c_name]
			participants[i] = {
				"display_name": "Jogador " + str(i + 1),
				"color_name": c_name,
				"color": c_color
			}
			color_index += 1
	
	# 2. Atribui para as IAs, continuando de onde parou
	for i in range(num_ias):
		if color_index < color_keys.size():
			var c_name = color_keys[color_index]
			var c_color = AVAILABLE_COLORS[c_name]
			var ia_id = "ia_" + str(i)
			participants[ia_id] = {
				"display_name": "IA " + str(i),
				"color_name": c_name,
				"color": c_color
			}
			color_index += 1
		else:
			# Caso de emergência se acabarem as cores
			var ia_id = "ia_" + str(i)
			participants[ia_id] = {
				"display_name": "IA " + str(i),
				"color_name": "gray",
				"color": Color.GRAY
			}
			
	print("Participantes configurados: ", participants)

# Pega a cor de qualquer participante (jogador ou IA) pelo seu ID
func get_participant_color(participant_id) -> Color:
	if participants.has(participant_id):
		return participants[participant_id].color
	return Color.GRAY # Retorna cinza se não encontrar

# Pega o nome de exibição de qualquer participante
func get_participant_display_name(participant_id) -> String:
	if participants.has(participant_id):
		return participants[participant_id].display_name
	return "Desconhecido" # Retorna um nome padrão se não encontrar
