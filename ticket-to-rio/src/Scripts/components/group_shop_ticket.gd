extends Control

# Este sinal agora é emitido pelo BOTÃO de comprar, não pelas cartas.
signal draw_button_pressed

# Parâmetros do shader da borda
const SHADER_PARAM_DRAW_BORDER = "draw_border"
const SHADER_PARAM_BORDER_COLOR = "border_color"
const SHADER_PARAM_BORDER_WIDTH = "border_pixel_width"

# Use @export para poder configurar a borda no Editor do Godot!
@export_group("Efeito da Borda")
@export var COR_BORDA_SELECIONADA: Color = Color.BLUE
@export var LARGURA_BORDA_SELECIONADA: float = 50.0

# Pool de tipos de carta. Usamos um dicionário para ligar o ID (string) à cena.
const POSSIBLE_CARD_TYPES = [
	preload("res://src/Scenes/GUI/components/card_roteRainbow.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteBlue.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteRed.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteYellow.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteGray.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteGreen.tscn"),
	preload("res://src/Scenes/GUI/components/card_roteOrange.tscn"),
	preload("res://src/Scenes/GUI/components/card_rotePink.tscn")
]

@onready var loja_container: VBoxContainer = $VBoxContainer
@onready var drawButton: Button = $drawButton
@onready var fundo: ColorRect = $ColorRect

const MAX_CARDS_IN_SHOP = 5
@onready var max_selection = 2
var rainbow_cont = 0

# Arrays para manter o estado e as referências dos nós
var card_nodes: Array[Control] = []
var card_selection_state: Array[bool] = []

# Prepara a loja para uma nova rodada, zerando os estados.
func deal_initial_cards():
	loja_container.visible = true
	fundo.visible = true
	drawButton.visible = true
	drawButton.disabled = false
	card_nodes.clear()
	card_selection_state.clear()
	for child in loja_container.get_children():
		child.queue_free()
	

	for i in range(MAX_CARDS_IN_SHOP):
		var card_scene = POSSIBLE_CARD_TYPES.pick_random()
		if card_scene == preload("res://src/Scenes/GUI/components/card_roteRainbow.tscn"):
			rainbow_cont+=1
			while rainbow_cont>1:
				card_scene = POSSIBLE_CARD_TYPES.pick_random()
				if card_scene != preload("res://src/Scenes/GUI/components/card_roteRainbow.tscn"):
					rainbow_cont-=1
		var card_instance = create_and_add_card(card_scene, i)
		card_nodes.append(card_instance)
		card_selection_state.append(false)
	rainbow_cont = 0

# Cria a carta e conecta o sinal passando o seu índice (i)
func create_and_add_card(card_scene: PackedScene, index: int) -> Control:
	var card_instance = card_scene.instantiate()
	loja_container.add_child(card_instance)
	card_instance.connect("cliquei", _on_click_input.bind(card_instance, index))
	return card_instance

func replace_card(old_card_node: Control):
	var index = old_card_node.get_index()
	old_card_node.queue_free()

	var card_scene = POSSIBLE_CARD_TYPES.pick_random()
	var new_card = create_and_add_card(card_scene, index)
	loja_container.move_child(new_card, index)
	card_nodes[index] = new_card

# A nova lógica de clique, similar à dos objetivos
func _on_click_input(card_node: Control, card_index: int):
	# Verifica se o jogador pode selecionar uma nova carta
	var current_selection_count = card_selection_state.count(true)
	var is_currently_selected = card_selection_state[card_index]

	# Permite a seleção se o limite não foi atingido, OU se o jogador está desselecionando uma carta
	if current_selection_count < max_selection or is_currently_selected:
		# Alterna o estado de seleção (true -> false, false -> true)
		card_selection_state[card_index] = not card_selection_state[card_index]
		
		# Atualiza a borda com base no novo estado
		_atualizar_borda_loja(card_node, card_selection_state[card_index])
	else:
		# Opcional: Adicionar um som ou efeito visual para indicar que a seleção está cheia
		print("Limite de seleção de %d cartas atingido." % max_selection)

# Pega as cartas marcadas e limpa a seleção para a próxima vez
func get_and_clear_selection() -> Array[Control]:
	var selection: Array[Control] = []
	for i in range(card_nodes.size()):
		# Se a carta no índice 'i' está marcada como true...
		if card_selection_state[i]:
			# ...adiciona o nó correspondente à seleção.
			selection.append(card_nodes[i])
	
	# Limpa a seleção (visual e lógica)
	for i in range(card_nodes.size()):
		if card_selection_state[i]: # Se estava selecionado
			card_selection_state[i] = false # Reseta o estado lógico
			_atualizar_borda_loja(card_nodes[i], false) # Remove a borda visual
	
	return selection

# A função da borda não precisa de mudanças, ela já recebe um booleano.
func _atualizar_borda_loja(card_node: Control, is_marked: bool):
	var sprite_node = card_node.get_child(0)
	if not sprite_node or not sprite_node.material is ShaderMaterial:
		return
	
	var material: ShaderMaterial = sprite_node.material
	material.set_shader_parameter(SHADER_PARAM_DRAW_BORDER, is_marked)
	if is_marked:
		material.set_shader_parameter(SHADER_PARAM_BORDER_COLOR, COR_BORDA_SELECIONADA)
		material.set_shader_parameter(SHADER_PARAM_BORDER_WIDTH, LARGURA_BORDA_SELECIONADA)
		
func _on_draw_button_pressed():
	emit_signal("draw_button_pressed")

func finish_shop():
	loja_container.visible = false
	fundo.visible = false
	drawButton.visible = false
	drawButton.disabled = true
