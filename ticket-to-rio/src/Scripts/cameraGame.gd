extends Camera2D

# Zoom
var zoom_step := 0.2
var min_zoom := Vector2(1, 1)
var max_zoom := Vector2(4, 4)
signal ajustezoom

# Movimento com mouse
var dragging := false

# Velocidade de movimento com WASD
var move_speed := 400

func _process(delta):
	#print("Zoom atual:", zoom)

	var input_vector := Vector2.ZERO

	# Movimento com WASD
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1

	if input_vector != Vector2.ZERO:
		position += input_vector.normalized() * move_speed * delta #/ zoom
	
	# Se passar das bordas do fundo, impedir a movimentação
	_limit_camera_to_bounds($"../fundo")
	emit_signal("ajustezoom")

func _limit_camera_to_bounds(fundo):
	if fundo == null:
		return

	var fundo_size : Vector2
	var fundo_position : Vector2

	fundo_size = fundo.texture.get_size() * fundo.scale
	fundo_position = fundo.global_position - fundo_size / 2.0

	# Tamanho visível da câmera ajustado pelo zoom
	var screen_size = get_viewport_rect().size / zoom
	var half_screen = screen_size / 2.0

	var min_bound = fundo_position + half_screen
	var max_bound = fundo_position + fundo_size - half_screen

	position.x = clamp(position.x, min_bound.x, max_bound.x)
	position.y = clamp(position.y, min_bound.y, max_bound.y)

func _unhandled_input(event):
	# Zoom com scroll
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoom_step, zoom_step)
			emit_signal("ajustezoom")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoom_step, zoom_step)
			emit_signal("ajustezoom")

		zoom.x = clamp(zoom.x, min_zoom.x, max_zoom.x)
		zoom.y = clamp(zoom.y, min_zoom.y, max_zoom.y)
		emit_signal("ajustezoom")

	# Início ou fim do arrasto com botão esquerdo do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	# Arrastando com movimento do mouse
	if event is InputEventMouseMotion and dragging:
		position += -event.relative / zoom 
