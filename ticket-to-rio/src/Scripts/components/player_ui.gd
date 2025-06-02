extends Control

# Array para guardar as texturas dos objetivos que o jogador selecionou
var meus_objetivos_selecionados: Array[Texture2D] = []
var custosByRote = {'card (1)': 8, 'card (2)': 9, 'card (3)': 9, 'card (4)': 7, 'card (5)': 8, 'card (6)': 8, 'card (7)': 8, 'card (8)': 8, 'card (9)': 8, 'card (10)': 9, 'card (11)': 9, 'card (12)': 5, 'card (13)': 6, 'card (14)': 6, 'card (15)': 6, 'card (16)': 6, 'card (17)': 7, 'card (18)': 7, 'card (19)': 7, 'card (20)': 13, 'card (21)': 13, 'card (22)': 13, 'card (23)': 13, 'card (24)': 13, 'card (25)': 5, 'card (26)': 5, 'card (27)': 5, 'card (28)': 18, 'card (29)': 18, 'card (30)': 19, 'card (31)': 21, 'card (32)': 22, 'card (33)': 22, 'card (34)': 22, 'card (35)': 13, 'card (36)': 13, 'card (37)': 14, 'card (38)': 14, 'card (39)': 15, 'card (40)': 16, 'card (41)': 16, 'card (42)': 17, 'card (43)': 17, 'card (44)': 10, 'card (45)': 10, 'card (46)': 11, 'card (47)': 11, 'card (48)': 0, 'card (49)': 0, 'card (50)': 12, 'card (51)': 13, 
					'card (52)': 6, 'card (53)': 7, 'card (54)': 7, 'card (55)': 7, 'card (56)': 8, 'card (57)': 8, 'card (58)': 9, 'card (59)': 10, 'card (60)': 22, 'card (61)': 3, 'card (62)': 4, 'card (63)': 5, 'card (64)': 5, 'card (65)': 5, 'card (66)': 6, 'card (67)': 6, 'card (68)': 18, 'card (69)': 19, 'card (70)': 21, 'card (71)': 21, 'card (72)': 22, 'card (73)': 22, 'card (74)': 22, 'card (75)': 22, 'card (76)': 14, 'card (77)': 15, 'card (78)': 16, 'card (79)': 16, 'card (80)': 17, 'card (81)': 17, 'card (82)':170, 'card (83)': 17, 'card (84)': 11, 'card (85)': 11, 'card (86)': 12, 'card (87)': 12, 'card (88)': 13, 'card (89)': 13, 'card (90)': 13, 'card (91)': 14, 'card (92)': 8, 'card (93)': 9, 'card (94)': 9, 'card (95)': 9, 'card (96)': 10, 'card (97)': 10, 'card (98)':11, 'card (99)': 11, 'card (100)': 5, 'card (101)': 5, 'card (102)': 6, 'card (103)': 6, 'card (104)': 6, 'card (105)': 7, 'card (106)': 7}

var manager_objetivos_node_path: NodePath = "/root/TutorialTest/ManagerObjetivos"
var manager_objetivos: Node

@onready var concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Text
@onready var nao_concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/Text

func _ready() -> void:
	if manager_objetivos_node_path:
		manager_objetivos = get_node_or_null(manager_objetivos_node_path)

	if manager_objetivos:
		manager_objetivos.connect("objetivos_escolhidos", Callable(self, "_on_manager_objetivos_escolhidos"))
	else:
		printerr("Nó ManagerObjetivos não encontrado ou não configurado no PlayerObjectivesDisplay. Verifique o NodePath.")

func _on_manager_objetivos_escolhidos(texturas_selecionadas: Array[Texture2D]) -> void:
	for textura in texturas_selecionadas:
		meus_objetivos_selecionados.append(textura)
	nao_concluidos.text = str(meus_objetivos_selecionados.size()) 
	print("PlayerObjectivesDisplay recebeu %d objetivos selecionados!" % meus_objetivos_selecionados.size())

func _on_objetivos_jogador_pressed() -> void:
	var janela_objetivos = $PanelContainer
	if !janela_objetivos.visible:
		if meus_objetivos_selecionados.is_empty():
			print("Nenhum objetivo selecionado para exibir.")
			return
		
		print("Exibindo os seguintes objetivos em uma nova janela:")
		var tr1 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect
		var tr2 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect2
		var tr3 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect3
		var tr4 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect4
		var tr5 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect5
		var tr6 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect6
		var tr7 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect7
		var tr8 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect8
		var tr9 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect9
		var tr10 = $PanelContainer/ScrollContainer/VBoxContainer/TextureRect10
		
		var objectives: Array[TextureRect] = [tr1, tr2, tr3, tr4, tr5, tr6, tr7, tr8, tr9, tr10]
		for index in range(meus_objetivos_selecionados.size()):
			objectives[index].texture = meus_objetivos_selecionados[index]
		
		janela_objetivos.show()
		
		for i in range(meus_objetivos_selecionados.size()):
			var textura: Texture2D = meus_objetivos_selecionados[i]
			print("  - Textura do Objetivo %d: %s" % [i+1, textura.resource_path if textura else "Nula"])
	else:
		janela_objetivos.hide()
