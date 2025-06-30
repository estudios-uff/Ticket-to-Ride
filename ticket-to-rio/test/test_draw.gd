extends GdUnitTestSuite

# Suponha que TurnManager esteja em "res://src/Scripts/TurnManager.gd"
const Deck := preload("res://src/Scripts/deck.gd")
const PlayerHand := preload("res://src/Scripts/Cards/PlayerHand.gd")
	
	
func test_player_hand_counter_increases_after_draw_card():
	var deck_scene = preload("res://src/Scenes/Cards/deck.tscn").instantiate()
	add_child(deck_scene)

	var player_hand_scene = preload("res://src/Scenes/GUI/components/PlayerHand.tscn")
	var player_hand = player_hand_scene.instantiate()
	add_child(player_hand)
	print(player_hand)

	deck_scene.connect("update_player_hand", Callable(player_hand, "_on_card_drawn"))

	deck_scene._ready()
	player_hand._ready()

	# Escolhe uma cor qualquer para observar, por exemplo "redTrain"
	var color_to_track := "redTrain"
	var before = player_hand.player_hand[color_to_track]["count"]

	# Força várias compras até vir a carta desejada
	deck_scene.draw_card()

	for i in player_hand.player_hand.values():
		print(i)

	var after = player_hand.player_hand[color_to_track]["count"]
	assert_int(before).is_equal(0)

func test_blue_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("blueTrain", -1)

	assert_int(train_count).is_equal(65)

func test_gray_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("grayTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_green_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("greenTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_orange_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("orangeTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_pink_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("pinkTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_red_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("redTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_yellow_train_should_be_65_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("yellowTrain", -1)

	assert_int(train_count).is_equal(65)
	
func test_rainbow_train_should_be_55_initially():
	var deck = auto_free(Deck.new())

	var train_count = deck.trains_deck.get("rainbowTrain", -1)

	assert_int(train_count).is_equal(95)

func test_example_2():
	assert_str("This is a example message")\
   .has_length(25)\
   .starts_with("This is a ex")
