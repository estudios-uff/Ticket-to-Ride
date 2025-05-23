extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_SLOT = 2

var screen_size
var card_being_dragged
var is_hovering_on_card
var player_hand_reference

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x,0,screen_size.x),
			clamp(mouse_pos.y,0,screen_size.y)
		)

func _ready() -> void:
	screen_size =get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_released", on_left_click_release)
	

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			#var card = raycast_check_for_card()
			#if card:
				#start_drag(card)
		#else:
			#if card_being_dragged:
				#finish_drag()

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1)
	
func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)
	var card_slot_found = raycast_check_for_card_slot()
	#print(card_slot_found.card_in_slot)
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		#card_slot_found.card_in_slot = true # DESCONMENTAR CASO QUERIA MULTIPLAS CARTAS NO SLOT DE DESCARTE
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged)
	card_being_dragged = null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
	
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1
		
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var param = PhysicsPointQueryParameters2D.new()
	param.position = get_global_mouse_position()
	param.collide_with_areas = true
	param.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(param)
	if result.size() > 0:
		#return result[0].collider.get_parent() #Gera bug de sobreposição de card
		return get_card_hightest_z_index(result)
	return null


func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var param = PhysicsPointQueryParameters2D.new()
	param.position = get_global_mouse_position()
	param.collide_with_areas = true
	param.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(param)
	#print('Card is drag: ',result[0].rid)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
func get_card_hightest_z_index(cards):
	var hightest_z_card =  cards[0].collider.get_parent()
	var hightest_z_index = hightest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > hightest_z_index:
			hightest_z_card = current_card
			hightest_z_index = current_card.z_index
			
	return hightest_z_card


func on_hovered_over_card(card):   
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

	
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func on_left_click_release():
	if card_being_dragged:
		finish_drag()
