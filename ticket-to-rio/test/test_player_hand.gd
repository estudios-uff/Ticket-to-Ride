extends GdUnitTestSuite

const PlayerHand := preload("res://src/Scripts/Cards/PlayerHand.gd")

func test_add_card_to_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Test adding a blue train card
	player_hand.add_card_to_hand("blueTrain")
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(1)
	
	# Test adding multiple cards of the same type
	player_hand.add_card_to_hand("blueTrain")
	player_hand.add_card_to_hand("blueTrain")
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(3)
	
	# Test adding different card types
	player_hand.add_card_to_hand("redTrain")
	assert_that(player_hand.player_hand["redTrain"]["count"]).is_equal(1)
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(3)

func test_add_invalid_card_to_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Test adding an invalid card type
	var initial_blue_count = player_hand.player_hand["blueTrain"]["count"]
	player_hand.add_card_to_hand("invalidCard")
	
	# Should not affect existing cards
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(initial_blue_count)

func test_remove_card_from_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Add some cards first
	player_hand.add_card_to_hand("blueTrain")
	player_hand.add_card_to_hand("blueTrain")
	player_hand.add_card_to_hand("redTrain")
	
	# Remove one blue train
	player_hand.remove_card_from_hand("blueTrain")
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(1)
	assert_that(player_hand.player_hand["redTrain"]["count"]).is_equal(1)
	
	# Remove the last blue train
	player_hand.remove_card_from_hand("blueTrain")
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(0)

func test_remove_card_from_empty_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Try to remove a card when count is 0
	player_hand.remove_card_from_hand("blueTrain")
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(0)

func test_remove_invalid_card_from_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Add a valid card
	player_hand.add_card_to_hand("blueTrain")
	var initial_count = player_hand.player_hand["blueTrain"]["count"]
	
	# Try to remove an invalid card
	player_hand.remove_card_from_hand("invalidCard")
	
	# Should not affect existing cards
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(initial_count)

func test_calculate_card_position():
	var player_hand = auto_free(PlayerHand.new())
	
	# Set center_screen_x manually to avoid viewport dependency
	player_hand.center_screen_x = -100
	
	# Test position calculation for different indices
	var pos_0 = player_hand.calculate_card_position(0)
	var pos_1 = player_hand.calculate_card_position(1)
	var pos_2 = player_hand.calculate_card_position(2)
	
	# Positions should be different for different indices
	assert_that(pos_0).is_not_equal(pos_1)
	assert_that(pos_1).is_not_equal(pos_2)
	assert_that(pos_0).is_not_equal(pos_2)

func test_player_hand_total_cards():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Initially should have 0 cards
	var total_cards = 0
	for train_type in player_hand.player_hand:
		total_cards += player_hand.player_hand[train_type]["count"]
	assert_that(total_cards).is_equal(0)
	
	# Add some cards
	player_hand.add_card_to_hand("blueTrain")
	player_hand.add_card_to_hand("redTrain")
	player_hand.add_card_to_hand("greenTrain")
	
	# Should have 3 cards total
	total_cards = 0
	for train_type in player_hand.player_hand:
		total_cards += player_hand.player_hand[train_type]["count"]
	assert_that(total_cards).is_equal(3)

func test_multiple_card_types_management():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "redTrain", "greenTrain", "yellowTrain", "orangeTrain", "pinkTrain", "grayTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Add cards of different types
	for card_type in train_types:
		player_hand.add_card_to_hand(card_type)
		player_hand.add_card_to_hand(card_type)  # Add 2 of each
	
	# Verify all have count 2
	for card_type in train_types:
		assert_that(player_hand.player_hand[card_type]["count"]).is_equal(2)
	
	# Remove one of each
	for card_type in train_types:
		player_hand.remove_card_from_hand(card_type)
	
	# Verify all have count 1
	for card_type in train_types:
		assert_that(player_hand.player_hand[card_type]["count"]).is_equal(1)

# Helper function to create a properly initialized PlayerHand for testing
func create_test_player_hand():
	var player_hand = auto_free(PlayerHand.new())
	
	# Create mock RichTextLabel nodes
	var mock_labels = {}
	var train_types = ["blueTrain", "grayTrain", "greenTrain", "orangeTrain", "pinkTrain", "redTrain", "yellowTrain", "rainbowTrain"]
	
	for train_type in train_types:
		var mock_label = RichTextLabel.new()
		mock_label.name = train_type.capitalize() + "Label"
		player_hand.add_child(mock_label)
		mock_labels[train_type] = mock_label
	
	# Manually set up the player_hand dictionary
	player_hand.player_hand = {
		"blueTrain": {"count": 0, "label": mock_labels["blueTrain"]},
		"grayTrain": {"count": 0, "label": mock_labels["grayTrain"]},
		"greenTrain": {"count": 0, "label": mock_labels["greenTrain"]},
		"orangeTrain": {"count": 0, "label": mock_labels["orangeTrain"]},
		"pinkTrain": {"count": 0, "label": mock_labels["pinkTrain"]},
		"redTrain": {"count": 0, "label": mock_labels["redTrain"]},
		"yellowTrain": {"count": 0, "label": mock_labels["yellowTrain"]},
		"rainbowTrain": {"count": 0, "label": mock_labels["rainbowTrain"]}
	}
	
	# Set center_screen_x manually
	player_hand.center_screen_x = -100
	
	return player_hand

func test_update_card_visibility():
	var player_hand = create_test_player_hand()
	
	# Add a card
	player_hand.add_card_to_hand("blueTrain")
	
	# Test update_card_visibility function
	player_hand.update_card_visibility("blueTrain")
	
	# Verify the count is still 1
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(1)

func test_update_card_visibility_invalid_card():
	var player_hand = create_test_player_hand()
	
	# Test update_card_visibility with invalid card
	player_hand.update_card_visibility("invalidCard")
	
	# Should not affect existing cards
	assert_that(player_hand.player_hand["blueTrain"]["count"]).is_equal(0) 
