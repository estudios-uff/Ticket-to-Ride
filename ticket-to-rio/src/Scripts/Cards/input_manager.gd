extends Node2D

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_CARD_DECK = 4

var card_manager_reference
var deck_reference

signal left_mouse_clicked
signal left_mouse_released

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_released")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var param = PhysicsPointQueryParameters2D.new()
	param.position = get_global_mouse_position()
	param.collide_with_areas = true
	var result = space_state.intersect_point(param)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			# CARTA FOI CLICADA
			var card_found = result[0].collider.get_parent()
			if card_found:
				#card_manager_reference.start_drag(card_found)
				card_manager_reference.select_card(card_found)
		elif result_collision_mask == COLLISION_MASK_CARD_DECK:
			# DECK FOI CLICADA
			deck_reference.draw_card()
			
			 
	return null
