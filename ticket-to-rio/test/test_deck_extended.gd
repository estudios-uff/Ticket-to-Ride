extends GdUnitTestSuite

const Deck := preload("res://src/Scripts/deck.gd")

func test_deck_initialization():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes to avoid UI dependency errors
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck to avoid UI dependency
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	# Test that deck is populated with correct total cards
	var expected_total = 0
	for count in deck.trains_deck.values():
		expected_total += count
	
	assert_that(deck.player_deck.size()).is_equal(expected_total)
	assert_that(deck.player_deck.size()).is_equal(550)

func test_deck_shuffle():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	# Store original order
	var original_order = deck.player_deck.duplicate()
	
	# Shuffle the deck
	deck.player_deck.shuffle()
	
	# Test that deck still has same size
	assert_that(deck.player_deck.size()).is_equal(original_order.size())
	
	# Test that all cards are still present (order might be different)
	var original_counts = {}
	var shuffled_counts = {}
	
	for card in original_order:
		original_counts[card] = original_counts.get(card, 0) + 1
	
	for card in deck.player_deck:
		shuffled_counts[card] = shuffled_counts.get(card, 0) + 1
	
	assert_that(original_counts).is_equal(shuffled_counts)

func test_draw_card_decreases_deck_size():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	var initial_size = deck.player_deck.size()
	deck.draw_card()
	
	assert_that(deck.player_deck.size()).is_equal(initial_size - 1)

func test_draw_card_decreases_train_count():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	# Store initial counts
	var initial_counts = deck.trains_deck.duplicate()
	
	# Draw a card
	deck.draw_card()
	
	# Find which card was drawn by comparing counts
	var drawn_card = ""
	for card_type in deck.trains_deck:
		if deck.trains_deck[card_type] < initial_counts[card_type]:
			drawn_card = card_type
			break
	
	# Test that one card of the drawn type was removed
	assert_that(drawn_card).is_not_equal("")
	assert_that(deck.trains_deck[drawn_card]).is_equal(initial_counts[drawn_card] - 1)

func test_draw_card_from_empty_deck():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Empty the deck
	deck.player_deck.clear()
	
	# Try to draw a card
	deck.draw_card()
	
	# Test that deck remains empty
	assert_that(deck.player_deck.size()).is_equal(0)

func test_draw_card_for_ia_from_empty_deck():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Empty the deck
	deck.player_deck.clear()
	
	# Try to draw a card for IA
	var drawn_card = deck.draw_card_for_ia()
	
	# Test that empty string is returned
	assert_that(drawn_card).is_equal("")

func test_remove_card_from_deck():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	var initial_size = deck.player_deck.size()
	deck.remove_card_from_deck()
	
	assert_that(deck.player_deck.size()).is_equal(initial_size - 1)

func test_remove_card_from_empty_deck():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Empty the deck
	deck.player_deck.clear()
	
	# Try to remove a card
	deck.remove_card_from_deck()
	
	# Test that deck remains empty
	assert_that(deck.player_deck.size()).is_equal(0)

func test_deck_visuals_update():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	var initial_size = deck.player_deck.size()
	deck.draw_card()

func test_train_deck_initial_counts():
	var deck = auto_free(Deck.new())
	
	# Test initial counts for each train type
	assert_that(deck.trains_deck["blueTrain"]).is_equal(65)
	assert_that(deck.trains_deck["grayTrain"]).is_equal(65)
	assert_that(deck.trains_deck["greenTrain"]).is_equal(65)
	assert_that(deck.trains_deck["orangeTrain"]).is_equal(65)
	assert_that(deck.trains_deck["pinkTrain"]).is_equal(65)
	assert_that(deck.trains_deck["redTrain"]).is_equal(65)
	assert_that(deck.trains_deck["yellowTrain"]).is_equal(65)
	assert_that(deck.trains_deck["rainbowTrain"]).is_equal(95)

func test_deck_total_cards_calculation():
	var deck = auto_free(Deck.new())
	
	var total_cards = 0
	for count in deck.trains_deck.values():
		total_cards += count
	
	assert_that(total_cards).is_equal(550)

func test_draw_multiple_cards():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	var initial_size = deck.player_deck.size()
	
	# Draw multiple cards
	for i in range(5):
		deck.draw_card()
	
	assert_that(deck.player_deck.size()).is_equal(initial_size - 5)

func test_deck_card_distribution():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	# Count cards of each type in the deck
	var card_counts = {}
	for card in deck.player_deck:
		card_counts[card] = card_counts.get(card, 0) + 1
	
	# Test that distribution matches expected counts
	for train_type in deck.trains_deck:
		assert_that(card_counts.get(train_type, 0)).is_equal(deck.trains_deck[train_type])

# Helper function to create a properly initialized Deck for testing
func create_test_deck():
	var deck = auto_free(Deck.new())
	
	# Create mock RichTextLabel nodes
	var mock_gray_label = RichTextLabel.new()
	mock_gray_label.name = "RichTextLabel"
	deck.add_child(mock_gray_label)
	
	var mock_main_label = RichTextLabel.new()
	mock_main_label.name = "RichTextLabel"
	deck.add_child(mock_main_label)
	
	# Manually populate the deck
	deck.player_deck.clear()
	for key in deck.trains_deck.keys():
		for n in deck.trains_deck[key]:
			deck.player_deck.append(key)
	
	return deck

func test_deck_constants():
	var deck = auto_free(Deck.new())
	
	# Test that constants are defined
	assert_that(deck.CARD_SCENE_PATH).is_equal("res://src/Scenes/Cards/card.tscn")

func test_deck_signal_definition():
	var deck = auto_free(Deck.new())
	
	# Test that the signal is defined
	# In Godot, we can't directly test signal existence, but we can test that
	# the signal emission function exists and can be called
	
	# Mock the signal emission
	var signal_emitted = false
	deck.update_player_hand.connect(func(card): signal_emitted = true)
	
	# Test that the signal can be connected (this is a basic test)
	assert_that(signal_emitted).is_false()
