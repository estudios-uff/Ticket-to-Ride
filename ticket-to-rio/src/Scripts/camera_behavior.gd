extends Node

@onready var camera: Camera2D = $"../../Camera2D"
var aparenciaConstante
@onready var deck: Node2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.ajustezoom.connect(_ajustaEscala)
	aparenciaConstante = deck.scale * camera.zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	deck.position = camera.get_screen_center_position()
	pass

func _ajustaEscala():
	deck.scale = aparenciaConstante / camera.zoom
	print(deck.scale)
	#if deck.scale <= Vector2(0.8,0.75):
		#deck.scale= Vector2(0.8,0.75)
