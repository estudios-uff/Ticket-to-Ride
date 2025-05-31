extends Node2D
class_name City

@export var city_name: String = "Unknown City"

@onready var label_node = $Label # Referência ao nó Label

@export var editor_mode: bool = false
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	label_node.text = city_name 
	$TextureRect.modulate.a = 0.3
	$Label.modulate.a = 0.3
	
	if editor_mode:
		set_process_input(true)
		
# Definir um sinal personalizado para ser emitido quando a cidade for clicada
signal city_clicked(city_node)
signal city_moved(city_node)

func _input(event: InputEvent):
	if not editor_mode: return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_viewport_rect().has_point(to_local(event.position)):
				is_dragging = true
				drag_offset = to_local(event.position) # Calcula o offset do clique
			elif not event.pressed and is_dragging:
				is_dragging = false
				emit_signal("city_moved", self) # Notifica o editor que a cidade foi movida

	if event is InputEventMouseMotion and is_dragging:
		position = event.position - drag_offset # Move a cidade baseando-se no offset
		queue_redraw() # Garante que a linha conectada redesenhe

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("LOG: Click detectado na Area2D da cidade: ", city_name, ". Editor Mode: ", editor_mode, ". Is Dragging: ", is_dragging)
		if not editor_mode or (editor_mode and not is_dragging): # Evita clique quando arrastando
			print("Cidade Clicada: ", city_name)
			# Emitir um sinal para a cena Map para indicar que esta cidade foi clicada
			# Para isso, precisamos conectar este sinal em tempo de execução na cena Map
			# ou criar um sinal aqui que a cena Map irá capturar.
			emit_signal("city_clicked", self) # Emite o sinal com a própria cidade como argumento


	



func _on_area_2d_mouse_entered() -> void:
	$TextureRect.modulate.a = 1.0
	$Label.modulate.a = 1.0


func _on_area_2d_mouse_exited() -> void:
	$TextureRect.modulate.a = 0.3
	$Label.modulate.a = 0.3
