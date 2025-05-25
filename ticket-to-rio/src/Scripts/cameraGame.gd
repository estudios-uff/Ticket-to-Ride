extends Camera2D

# Zoom
var zoom_step := 0.2
var min_zoom := Vector2(1, 1)
var max_zoom := Vector2(4, 4)

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
		position += input_vector.normalized() * move_speed * delta

func _unhandled_input(event):
	# Zoom com scroll
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom -= Vector2(zoom_step, zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom += Vector2(zoom_step, zoom_step)

		zoom.x = clamp(zoom.x, min_zoom.x, max_zoom.x)
		zoom.y = clamp(zoom.y, min_zoom.y, max_zoom.y)

	# Início ou fim do arrasto com botão esquerdo do mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	# Arrastando com movimento do mouse
	if event is InputEventMouseMotion and dragging:
		position += -event.relative * zoom 
