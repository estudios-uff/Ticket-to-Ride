extends GdUnitTestSuite

const CardManager := preload("res://src/Scripts/Cards/card_manager.gd")

func test_card_manager_initialization():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually to avoid viewport dependency
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Test that screen size is set
	assert_that(card_manager.screen_size).is_not_null()
	assert_that(card_manager.screen_size.x).is_equal(1920.0)
	assert_that(card_manager.screen_size.y).is_equal(1080.0)
	
	# Test that card_being_dragged starts as null
	assert_that(card_manager.card_being_dragged).is_null()

func test_start_drag():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Create a mock card node
	var mock_card = Node2D.new()
	mock_card.scale = Vector2(0.5, 0.5)  # Set initial scale
	add_child(mock_card)
	
	# Start dragging the card
	card_manager.start_drag(mock_card)
	
	# Test that card is being dragged
	assert_that(card_manager.card_being_dragged).is_equal(mock_card)
	assert_that(mock_card.scale).is_equal(Vector2(1, 1))
	
	# Clean up
	remove_child(mock_card)
	mock_card.queue_free()

func test_highlight_card_on():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Create a mock card
	var mock_card = Node2D.new()
	mock_card.scale = Vector2(1, 1)
	mock_card.z_index = 1
	add_child(mock_card)
	
	# Highlight the card
	card_manager.highlight_card(mock_card, true)
	
	# Test that card is highlighted
	assert_that(mock_card.z_index).is_equal(2)
	
	# Clean up
	remove_child(mock_card)
	mock_card.queue_free()

func test_highlight_card_off():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Create a mock card
	var mock_card = Node2D.new()
	mock_card.scale = Vector2(1.1, 1.1)
	mock_card.z_index = 2
	add_child(mock_card)
	
	# Remove highlight from the card
	card_manager.highlight_card(mock_card, false)
	
	# Test that card is not highlighted
	assert_that(mock_card.scale).is_equal(Vector2(1, 1))
	assert_that(mock_card.z_index).is_equal(1)
	
	# Clean up
	remove_child(mock_card)
	mock_card.queue_free()

func test_on_hovered_off_card_while_dragging():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Create a mock card
	var mock_card = Node2D.new()
	add_child(mock_card)
	
	# Set dragging state
	card_manager.is_hovering_on_card = true
	card_manager.card_being_dragged = mock_card
	
	# Hover off card while dragging
	card_manager.on_hovered_off_card(mock_card)
	
	# Test that hovering state remains true (shouldn't change while dragging)
	assert_that(card_manager.is_hovering_on_card).is_true()
	
	# Clean up
	remove_child(mock_card)
	mock_card.queue_free()

func test_card_manager_constants():
	var card_manager = auto_free(CardManager.new())
	
	# Test that constants are defined
	assert_that(CardManager.COLLISION_MASK_CARD).is_equal(1)
	assert_that(CardManager.COLLISION_MASK_CARD_SLOT).is_equal(2)

func test_on_left_click_release_without_dragged_card():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Ensure no card is being dragged
	card_manager.card_being_dragged = null
	
	# Release left click (should not throw error)
	card_manager.on_left_click_release()
	
	# Test that nothing changed
	assert_that(card_manager.card_being_dragged).is_null()

func test_card_manager_screen_size_setting():
	var card_manager = auto_free(CardManager.new())
	
	# Test setting different screen sizes
	card_manager.screen_size = Vector2(800, 600)
	assert_that(card_manager.screen_size).is_equal(Vector2(800, 600))
	
	card_manager.screen_size = Vector2(1920, 1080)
	assert_that(card_manager.screen_size).is_equal(Vector2(1920, 1080))
	
	card_manager.screen_size = Vector2(2560, 1440)
	assert_that(card_manager.screen_size).is_equal(Vector2(2560, 1440))

func test_card_manager_player_hand_reference():
	var card_manager = auto_free(CardManager.new())
	
	# Test setting player hand reference
	var mock_player_hand = Node2D.new()
	card_manager.player_hand_reference = mock_player_hand
	
	assert_that(card_manager.player_hand_reference).is_equal(mock_player_hand)
	
	# Clean up
	mock_player_hand.queue_free()

func test_card_manager_tween_management():
	var card_manager = auto_free(CardManager.new())
	
	# Set screen size manually
	card_manager.screen_size = Vector2(1920, 1080)
	
	# Test that tween starts as null
	assert_that(card_manager.tween).is_null()
	
	# Create a mock card for highlighting
	var mock_card = Node2D.new()
	add_child(mock_card)
	
	# Test highlighting (which creates a tween)
	card_manager.highlight_card(mock_card, true)
	
	# Test that tween is created
	assert_that(card_manager.tween).is_not_null()
	
	# Test unhighlighting (which kills the tween)
	card_manager.highlight_card(mock_card, false)
	
	# Clean up
	remove_child(mock_card)
	mock_card.queue_free()
