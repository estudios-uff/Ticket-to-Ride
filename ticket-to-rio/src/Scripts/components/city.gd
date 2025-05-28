extends Node2D

@export var city_name: String = "Unknown City"

@onready var label_node = $Label # Referência ao nó Label

func _ready():
	label_node.text = city_name # Define o texto do Label com o nome da cidade

# Definir um sinal personalizado para ser emitido quando a cidade for clicada
signal city_clicked(city_node)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Cidade Clicada: ", city_name)
		# Emitir um sinal para a cena Map para indicar que esta cidade foi clicada
		# Para isso, precisamos conectar este sinal em tempo de execução na cena Map
		# ou criar um sinal aqui que a cena Map irá capturar.
		emit_signal("city_clicked", self) # Emite o sinal com a própria cidade como argumento
