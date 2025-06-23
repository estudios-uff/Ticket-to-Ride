extends Control
class_name InfoPopupPopup

@onready var message_label: Label = $Panel/Label
@onready var hide_timer: Timer = $Timer

func _ready():
	# Conecta o sinal 'timeout' do Timer ao método _on_hide_timer_timeout
	hide_timer.timeout.connect(_on_hide_timer_timeout)

func show_message(message: String, display_position: Vector2):
	message_label.text = message
	position = display_position # Define a posição do pop-up
	visible = true # Torna o pop-up visível
	hide_timer.start() # Inicia o timer para ocultar o pop-up

func _on_hide_timer_timeout():
	queue_free()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
	
