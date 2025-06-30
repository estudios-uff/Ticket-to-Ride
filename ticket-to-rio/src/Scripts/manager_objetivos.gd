extends Node2D

signal objetivos_escolhidos(texturas_objetivos_selecionados: Array[Texture2D])

var todas_as_cartas: Array[Texture2D] = []

var caminhos_das_cartas: Array[String] = [
	"res://images/cards/card (1).png",
	"res://images/cards/card (2).png",
	"res://images/cards/card (3).png",
	"res://images/cards/card (4).png",
	#"res://images/cards/card (5).png",
	"res://images/cards/card (6).png",
	"res://images/cards/card (7).png",
	"res://images/cards/card (8).png",
	"res://images/cards/card (9).png",
	"res://images/cards/card (10).png",
	"res://images/cards/card (11).png",
	"res://images/cards/card (12).png",
	"res://images/cards/card (13).png",
	"res://images/cards/card (14).png",
	"res://images/cards/card (15).png",
	"res://images/cards/card (16).png",
	"res://images/cards/card (17).png",
	"res://images/cards/card (18).png",
	"res://images/cards/card (19).png",
	"res://images/cards/card (20).png",
	"res://images/cards/card (21).png",
	"res://images/cards/card (22).png",
	"res://images/cards/card (23).png",
	"res://images/cards/card (24).png",
	"res://images/cards/card (25).png",
	"res://images/cards/card (26).png",
	"res://images/cards/card (27).png",
	"res://images/cards/card (28).png",
	"res://images/cards/card (29).png",
	"res://images/cards/card (30).png",
	"res://images/cards/card (31).png",
	"res://images/cards/card (32).png",
	"res://images/cards/card (33).png",
	"res://images/cards/card (34).png",
	"res://images/cards/card (35).png",
	"res://images/cards/card (36).png",
	"res://images/cards/card (37).png",
	"res://images/cards/card (38).png",
	"res://images/cards/card (39).png",
	"res://images/cards/card (40).png",
	"res://images/cards/card (41).png",
	"res://images/cards/card (42).png",
	"res://images/cards/card (43).png",
	"res://images/cards/card (44).png",
	"res://images/cards/card (45).png",
	"res://images/cards/card (46).png",
	"res://images/cards/card (47).png",
	"res://images/cards/card (48).png",
	"res://images/cards/card (49).png",
	"res://images/cards/card (50).png",
	"res://images/cards/card (51).png",
	#"res://images/cards/card (52).png",
	"res://images/cards/card (53).png",
	"res://images/cards/card (54).png",
	"res://images/cards/card (55).png",
	#"res://images/cards/card (56).png",
	"res://images/cards/card (57).png",
	"res://images/cards/card (58).png",
	"res://images/cards/card (59).png",
	"res://images/cards/card (60).png",
	#"res://images/cards/card (61).png",
	#"res://images/cards/card (62).png",
	#"res://images/cards/card (63).png",
	"res://images/cards/card (64).png",
	"res://images/cards/card (65).png",
	#"res://images/cards/card (66).png",
	"res://images/cards/card (67).png",
	#"res://images/cards/card (68).png",
	"res://images/cards/card (70).png",
	"res://images/cards/card (71).png",
	"res://images/cards/card (72).png",
	"res://images/cards/card (73).png",
	"res://images/cards/card (74).png",
	"res://images/cards/card (75).png",
	"res://images/cards/card (76).png",
	"res://images/cards/card (77).png",
	"res://images/cards/card (78).png",
	"res://images/cards/card (79).png",
	"res://images/cards/card (80).png",
	"res://images/cards/card (81).png",
	"res://images/cards/card (82).png",
	"res://images/cards/card (83).png",
	"res://images/cards/card (84).png",
	"res://images/cards/card (85).png",
	"res://images/cards/card (86).png",
	"res://images/cards/card (87).png",
	"res://images/cards/card (88).png",
	"res://images/cards/card (89).png",
	"res://images/cards/card (90).png",
	"res://images/cards/card (91).png",
	#"res://images/cards/card (92).png",
	"res://images/cards/card (93).png",
	#"res://images/cards/card (94).png",
	"res://images/cards/card (95).png",
	"res://images/cards/card (96).png",
	"res://images/cards/card (97).png",
	"res://images/cards/card (98).png",
	"res://images/cards/card (99).png",
	"res://images/cards/card (100).png",
	"res://images/cards/card (101).png",
	#"res://images/cards/card (102).png",
	#"res://images/cards/card (103).png",
	"res://images/cards/card (104).png"
	#"res://images/cards/card (105).png",
	#"res://images/cards/card (106).png"
]

@onready var placeholder_carta_1: TextureRect = $Objetivo1
@onready var placeholder_carta_2: TextureRect = $Objetivo2
@onready var placeholder_carta_3: TextureRect = $Objetivo3

var objetivos_marcados: Array[bool] = [false, false, false]
var cartas_objetivo_marcadas: Array[TextureRect]

const SHADER_PARAM_DRAW_BORDER = "draw_border"
const SHADER_PARAM_BORDER_COLOR = "border_color"
const SHADER_PARAM_BORDER_WIDTH = "border_pixel_width"
const COR_BORDA_SELECIONADA: Color = Color.BLUE
const LARGURA_BORDA_SELECIONADA: float = 10.0

var tentativas: int = 2

func _ready() -> void:
	for caminho_carta in caminhos_das_cartas:
		var textura_carta: Texture = load(caminho_carta)
		if textura_carta:
			todas_as_cartas.append(textura_carta)
		else:
			printerr("Erro ao carregar a textura: ", caminho_carta)

	# Verificar se temos cartas suficientes para selecionar
	if todas_as_cartas.size() < 3:
		printerr("Não há cartas suficientes carregadas para selecionar 3.")
		return
	
	if placeholder_carta_1 and placeholder_carta_1.material is ShaderMaterial:
		placeholder_carta_1.gui_input.connect(_on_objetivo_gui_input.bind(placeholder_carta_1, 0))
	else:
		printerr("Objetivo1 ou seu ShaderMaterial não está configurado corretamente no editor.")
		
	if placeholder_carta_2 and placeholder_carta_2.material is ShaderMaterial:
		placeholder_carta_2.gui_input.connect(_on_objetivo_gui_input.bind(placeholder_carta_2, 1))
	else:
		printerr("Objetivo2 ou seu ShaderMaterial não está configurado corretamente no editor.")

	if placeholder_carta_3 and placeholder_carta_3.material is ShaderMaterial:
		placeholder_carta_3.gui_input.connect(_on_objetivo_gui_input.bind(placeholder_carta_3, 2))
	else:
		printerr("Objetivo3 ou seu ShaderMaterial não está configurado corretamente no editor.")
	
	gerar_objetivos()

func get_random_objectives(amount: int) -> Array[Texture2D]:
	# Cria um array vazio para armazenar o resultado
	var selecionadas: Array[Texture2D] = []
	
	# Garante que não tentemos pegar mais cartas do que existem no baralho.
	# Se o baralho estiver vazio, retorna um array vazio para evitar erros.
	if todas_as_cartas.is_empty():
		printerr("ManagerObjetivos: Não há cartas no baralho de objetivos para selecionar.")
		return selecionadas
	
	# Embaralha a lista de todas as cartas para garantir a aleatoriedade
	todas_as_cartas.shuffle()
	
	# Pega a quantidade de cartas solicitada do topo da lista embaralhada.
	# A função 'min' garante que o laço não tente acessar um índice que não existe,
	# caso 'amount' seja maior que o número de cartas restantes.
	for i in range(min(amount, todas_as_cartas.size())):
		selecionadas.append(todas_as_cartas[i])
		
	return selecionadas

func gerar_objetivos():
	var cartas_selecionadas: Array[Texture] = []
	var indices_usados: Array[int] = []

	# Randomizar o gerador de números aleatórios
	randomize()

	while cartas_selecionadas.size() < 3 and todas_as_cartas.size() > 0:
		var indice_aleatorio: int = randi() % todas_as_cartas.size()
		
		if not indice_aleatorio in indices_usados:
			cartas_selecionadas.append(todas_as_cartas[indice_aleatorio])
			indices_usados.append(indice_aleatorio)

	if cartas_selecionadas.size() == 3:
		placeholder_carta_1.texture = cartas_selecionadas[0]
		placeholder_carta_2.texture = cartas_selecionadas[1]
		placeholder_carta_3.texture = cartas_selecionadas[2]
		
		var nova_escala: Vector2 = Vector2(0.2, 0.2)
		placeholder_carta_1.scale = nova_escala
		placeholder_carta_2.scale = nova_escala
		placeholder_carta_3.scale = nova_escala

		_atualizar_borda_objetivo(placeholder_carta_1, objetivos_marcados[0])
		_atualizar_borda_objetivo(placeholder_carta_2, objetivos_marcados[1])
		_atualizar_borda_objetivo(placeholder_carta_3, objetivos_marcados[2])
		
		cartas_objetivo_marcadas = [placeholder_carta_1, placeholder_carta_2, placeholder_carta_3]
		
		print("Cartas selecionadas, atribuídas e redimensionadas!")
	else:
		printerr("Não foi possível selecionar 3 cartas únicas.")

func iniciar_selecao_de_objetivos() -> void:
	# Reseta o estado para um novo jogador
	objetivos_marcados = [false, false, false]
	tentativas = 2
	$GerarNovamente.text = "Gerar novos: " + str(tentativas)
	
	# Gera um novo conjunto de 3 objetivos
	gerar_objetivos()
	
	# Mostra a tela de seleção
	show()
	$"../EndTurnButton".disabled = true

# Função chamada quando ocorre um evento de input GUI em um dos TextureRects
func _on_objetivo_gui_input(event: InputEvent, texture_rect_node: TextureRect, objective_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		objetivos_marcados[objective_index] = not objetivos_marcados[objective_index]
		_atualizar_borda_objetivo(texture_rect_node, objetivos_marcados[objective_index])
		
		print("Objetivo %d clicado. Marcado: %s" % [objective_index + 1, objetivos_marcados[objective_index]])

# Função auxiliar para atualizar o visual da borda de um TextureRect específico
func _atualizar_borda_objetivo(texture_rect_node: TextureRect, is_marked: bool) -> void:
	if not texture_rect_node:
		printerr("Tentativa de atualizar borda de um nó nulo.")
		return

	var material: ShaderMaterial = texture_rect_node.material as ShaderMaterial
	if material:
		material.set_shader_parameter(SHADER_PARAM_DRAW_BORDER, is_marked)
		if is_marked:
			material.set_shader_parameter(SHADER_PARAM_BORDER_COLOR, COR_BORDA_SELECIONADA)
			material.set_shader_parameter(SHADER_PARAM_BORDER_WIDTH, LARGURA_BORDA_SELECIONADA)
	else:
		printerr("ShaderMaterial não encontrado no nó: ", texture_rect_node.name, " para atualizar a borda.")


func _on_gerar_novamente_pressed() -> void:
	if tentativas > 0:
		gerar_objetivos()
		tentativas -= 1
		$GerarNovamente.text = "Gerar novos: " + str(tentativas)

func _on_ok_pressed() -> void:
	if objetivos_marcados.count(true) >= 2: # Pelo menos 2 objetivos devem ser marcados
		var selecionadas: Array[Texture2D] = []
		for i in range(objetivos_marcados.size()):
			if objetivos_marcados[i]:
				if cartas_objetivo_marcadas[i] and cartas_objetivo_marcadas[i].texture:
					selecionadas.append(cartas_objetivo_marcadas[i].texture)
				else:
					printerr("Placeholder %d ou sua textura é nula ao tentar coletar objetivos." % i)
		
		emit_signal("objetivos_escolhidos", selecionadas)
		hide()
	else:
		print("Selecione pelo menos 2 objetivos para continuar.")


func _on_hide_button_pressed() -> void:
	$TextureRect.visible = !$TextureRect.visible
	$Objetivo1.visible = !$Objetivo1.visible
	$Objetivo2.visible = !$Objetivo2.visible
	$Objetivo3.visible = !$Objetivo3.visible
	$GerarNovamente.visible = !$GerarNovamente.visible
	$GerarNovamente.disabled = !$GerarNovamente.disabled
	$OK.visible = !$OK.visible
	$OK.disabled = !$OK.disabled
	$Label.visible = !$Label.visible
