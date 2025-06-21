# Script PlayerUi.gd MODIFICADO

extends Control

var meus_objetivos_selecionados: Array[Texture2D] = []
# O dicionário de custos não é usado neste script, pode ser removido ou movido para onde for relevante
# var custosByRote = {...} 

# Remova as referências e a função _ready() que conectava o sinal
# var manager_objetivos_node_path: NodePath = "/root/TutorialTest/ManagerObjetivos"
# var manager_objetivos: Node

@onready var concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer/Text
@onready var nao_concluidos = $CenterContainer/VBoxContainer/HBoxContainer3/HBoxContainer2/Text
# Uma forma mais robusta de pegar os TextureRects
@onready var objectives_container = $PanelContainer/ScrollContainer/VBoxContainer

# REMOVIDO _ready() e _on_manager_objetivos_escolhidos(..)

# --- NOVA FUNÇÃO PÚBLICA ---
# O TurnManager vai chamar esta função para entregar os objetivos.
func add_objetivos(novos_objetivos: Array[Texture2D]):
	for textura in novos_objetivos:
		meus_objetivos_selecionados.append(textura)
	
	# Atualiza o contador de objetivos não concluídos
	nao_concluidos.text = str(meus_objetivos_selecionados.size())
	print("%s recebeu %d novos objetivos!" % [name, novos_objetivos.size()])


func _on_objetivos_jogador_pressed() -> void:
	var janela_objetivos = $PanelContainer
	janela_objetivos.visible = not janela_objetivos.visible

	# Se a janela for ficar visível, atualiza as texturas
	if janela_objetivos.visible:
		if meus_objetivos_selecionados.is_empty():
			print("Nenhum objetivo selecionado para exibir.")
			return
		
		print("Exibindo %d objetivos..." % meus_objetivos_selecionados.size())
		
		# Pega todos os TextureRects dentro do container
		var objective_rects = objectives_container.get_children()
		
		# Limpa as texturas antigas primeiro
		for rect in objective_rects:
			rect.texture = null
			
		# Atribui as novas texturas
		for i in range(min(meus_objetivos_selecionados.size(), objective_rects.size())):
			objective_rects[i].texture = meus_objetivos_selecionados[i]
