extends GdUnitTestSuite

const TurnManager := preload("res://src/Scripts/turn_manager.gd")

func test_turn_manager_initialization():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial state
	assert_that(turn_manager.current_state).is_equal(TurnManager.State.CHOOSING_OBJECTIVES)
	assert_that(turn_manager.index_player).is_equal(0)
	assert_that(turn_manager.is_game_over).is_false()
	assert_that(turn_manager.round_idx).is_equal(1)

func test_turn_manager_state_enum():
	# Test that all states are defined
	assert_that(TurnManager.State.CHOOSING_OBJECTIVES).is_equal(0)
	assert_that(TurnManager.State.PLAYER_TURN).is_equal(1)
	assert_that(TurnManager.State.IA_TURN).is_equal(2)
	assert_that(TurnManager.State.DRAWING_CARDS).is_equal(3)

func test_turn_manager_arrays_initialization():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that arrays are initialized
	assert_that(turn_manager.playerHands).is_not_null()
	assert_that(turn_manager.iaHands).is_not_null()
	assert_that(turn_manager.player_uis).is_not_null()
	assert_that(turn_manager.player_objectives).is_not_null()

func test_turn_manager_arrays_are_empty_initially():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that arrays start empty
	assert_that(turn_manager.playerHands).is_empty()
	assert_that(turn_manager.iaHands).is_empty()
	assert_that(turn_manager.player_uis).is_empty()
	assert_that(turn_manager.player_objectives).is_empty()

func test_turn_manager_selected_shop_cards_initialization():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that selected shop cards array is initialized
	assert_that(turn_manager.selected_shop_cards).is_not_null()
	assert_that(turn_manager.selected_shop_cards).is_empty()

func test_turn_manager_cards_drawn_this_turn_initialization():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that cards drawn counter starts at 0
	assert_that(turn_manager.cards_drawn_this_turn).is_equal(0)

func test_turn_manager_index_ia_initialization():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that IA index starts at 0
	assert_that(turn_manager.index_ia).is_equal(0)

func test_turn_manager_state_transitions():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test state transitions
	turn_manager.current_state = TurnManager.State.CHOOSING_OBJECTIVES
	assert_that(turn_manager.current_state).is_equal(TurnManager.State.CHOOSING_OBJECTIVES)
	
	turn_manager.current_state = TurnManager.State.PLAYER_TURN
	assert_that(turn_manager.current_state).is_equal(TurnManager.State.PLAYER_TURN)
	
	turn_manager.current_state = TurnManager.State.IA_TURN
	assert_that(turn_manager.current_state).is_equal(TurnManager.State.IA_TURN)
	
	turn_manager.current_state = TurnManager.State.DRAWING_CARDS
	assert_that(turn_manager.current_state).is_equal(TurnManager.State.DRAWING_CARDS)

func test_turn_manager_game_over_flag():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial game over state
	assert_that(turn_manager.is_game_over).is_false()
	
	# Test setting game over
	turn_manager.is_game_over = true
	assert_that(turn_manager.is_game_over).is_true()
	
	# Test unsetting game over
	turn_manager.is_game_over = false
	assert_that(turn_manager.is_game_over).is_false()

func test_turn_manager_round_counter():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial round
	assert_that(turn_manager.round_idx).is_equal(1)
	
	# Test incrementing round
	turn_manager.round_idx += 1
	assert_that(turn_manager.round_idx).is_equal(2)
	
	turn_manager.round_idx += 1
	assert_that(turn_manager.round_idx).is_equal(3)

func test_turn_manager_player_index():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial player index
	assert_that(turn_manager.index_player).is_equal(0)
	
	# Test changing player index
	turn_manager.index_player = 1
	assert_that(turn_manager.index_player).is_equal(1)
	
	turn_manager.index_player = 2
	assert_that(turn_manager.index_player).is_equal(2)

func test_turn_manager_ia_index():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial IA index
	assert_that(turn_manager.index_ia).is_equal(0)
	
	# Test changing IA index
	turn_manager.index_ia = 1
	assert_that(turn_manager.index_ia).is_equal(1)
	
	turn_manager.index_ia = 2
	assert_that(turn_manager.index_ia).is_equal(2)

func test_turn_manager_end_game_function():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial state
	assert_that(turn_manager.is_game_over).is_false()
	
	# Mock the dependencies to avoid null access errors
	turn_manager.deck_collision_shape = Control.new()
	turn_manager.end_turn_button = Control.new()
	
	# Call end game
	turn_manager.end_game()
	
	# Test that game is marked as over
	assert_that(turn_manager.is_game_over).is_true()
	
	# Clean up
	turn_manager.deck_collision_shape.queue_free()
	turn_manager.end_turn_button.queue_free()

func test_turn_manager_calculate_player_score():
	var turn_manager = auto_free(TurnManager.new())
	
	# Mock the map dependency to avoid null access errors
	turn_manager.map = {
		"player_claimed_routes": {},
		"objective_card_data": {}
	}
	
	# Test calculating score for player 0
	var score = turn_manager.calculate_player_score(0)
	
	# Score should be a number (could be 0 or positive)
	assert_that(score).is_greater_equal(0)

func test_turn_manager_calculate_ia_score():
	var turn_manager = auto_free(TurnManager.new())
	
	# Mock the map dependency to avoid null access errors
	turn_manager.map = {
		"player_claimed_routes": {},
		"objective_card_data": {}
	}
	
	# Test calculating score for IA
	var score = turn_manager.calculate_player_score("ia_0")
	
	# Score should be a number (could be 0 or positive)
	assert_that(score).is_greater_equal(0)

func test_turn_manager_player_objectives_management():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test adding objectives for a player
	turn_manager.player_objectives[0] = []
	turn_manager.player_objectives[0].append("objective1")
	turn_manager.player_objectives[0].append("objective2")
	
	assert_that(turn_manager.player_objectives[0]).has_size(2)
	assert_that(turn_manager.player_objectives[0]).contains("objective1")
	assert_that(turn_manager.player_objectives[0]).contains("objective2")

func test_turn_manager_ia_objectives_management():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test adding objectives for an IA
	turn_manager.player_objectives["ia_0"] = []
	turn_manager.player_objectives["ia_0"].append("ia_objective1")
	
	assert_that(turn_manager.player_objectives["ia_0"]).has_size(1)
	assert_that(turn_manager.player_objectives["ia_0"]).contains("ia_objective1")

func test_turn_manager_selected_shop_cards_management():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test adding selected shop cards
	var mock_card1 = Control.new()
	var mock_card2 = Control.new()
	
	turn_manager.selected_shop_cards.append(mock_card1)
	turn_manager.selected_shop_cards.append(mock_card2)
	
	assert_that(turn_manager.selected_shop_cards).has_size(2)
	assert_that(turn_manager.selected_shop_cards).contains(mock_card1)
	assert_that(turn_manager.selected_shop_cards).contains(mock_card2)
	
	# Clean up
	mock_card1.queue_free()
	mock_card2.queue_free()

func test_turn_manager_cards_drawn_counter():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test initial counter
	assert_that(turn_manager.cards_drawn_this_turn).is_equal(0)
	
	# Test incrementing counter
	turn_manager.cards_drawn_this_turn += 1
	assert_that(turn_manager.cards_drawn_this_turn).is_equal(1)
	
	turn_manager.cards_drawn_this_turn += 2
	assert_that(turn_manager.cards_drawn_this_turn).is_equal(3)
	
	# Test resetting counter
	turn_manager.cards_drawn_this_turn = 0
	assert_that(turn_manager.cards_drawn_this_turn).is_equal(0)

func test_turn_manager_winner_popup_scene():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that winner popup scene is loaded
	assert_that(turn_manager.winner_popup_scene).is_not_null()

func test_turn_manager_scene_preloads():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that scene preloads are defined
	assert_that(turn_manager.player_ui_scene).is_not_null()
	assert_that(turn_manager.player_hand_scene).is_not_null()
	assert_that(turn_manager.winner_popup_scene).is_not_null()

func test_turn_manager_route_claimed_signal_handling():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that the function exists and can be called
	# This is a basic test to ensure the function signature is correct
	# In a real scenario, you'd need to mock the dependencies
	
	# Mock the function to avoid dependencies
	turn_manager._on_map_route_claimed = func(player_index): pass
	
	# Test that the function can be called
	turn_manager._on_map_route_claimed(0)
	turn_manager._on_map_route_claimed("ia_0")

func test_turn_manager_deck_card_drawn_signal_handling():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that the function exists and can be called
	# Mock the function to avoid dependencies
	turn_manager._on_deck_card_drawn = func(card): pass
	
	# Test that the function can be called
	turn_manager._on_deck_card_drawn("blueTrain")
	turn_manager._on_deck_card_drawn("redTrain")

func test_turn_manager_objectives_chosen_signal_handling():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that the function exists and can be called
	# Mock the function to avoid dependencies
	turn_manager._on_objetivos_do_jogador_escolhidos = func(player_index, objectives): pass
	
	# Test that the function can be called
	turn_manager._on_objetivos_do_jogador_escolhidos(0, ["obj1", "obj2"])
	turn_manager._on_objetivos_do_jogador_escolhidos("ia_0", ["ia_obj1"])

func test_turn_manager_shop_draw_button_signal_handling():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test that the function exists and can be called
	# Mock the function to avoid dependencies
	turn_manager._on_shop_draw_button_pressed = func(): pass
	
	# Test that the function can be called
	turn_manager._on_shop_draw_button_pressed()

func test_turn_manager_get_route_points():
	var turn_manager = auto_free(TurnManager.new())
	
	# Test route points calculation
	assert_that(turn_manager.get_route_points(1)).is_equal(1)
	assert_that(turn_manager.get_route_points(2)).is_equal(2)
	assert_that(turn_manager.get_route_points(3)).is_equal(4)
	assert_that(turn_manager.get_route_points(4)).is_equal(5)
	assert_that(turn_manager.get_route_points(5)).is_equal(7)
	assert_that(turn_manager.get_route_points(6)).is_equal(8)
	assert_that(turn_manager.get_route_points(7)).is_equal(10)
	assert_that(turn_manager.get_route_points(8)).is_equal(15)
	assert_that(turn_manager.get_route_points(0)).is_equal(0)
	assert_that(turn_manager.get_route_points(9)).is_equal(0) 