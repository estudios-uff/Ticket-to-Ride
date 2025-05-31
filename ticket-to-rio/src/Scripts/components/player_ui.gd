extends Control

# Array para guardar as texturas dos objetivos que o jogador selecionou
var meus_objetivos_selecionados: Array[Texture2D] = []

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
