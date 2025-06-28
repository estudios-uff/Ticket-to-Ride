class_name GdUnitExampleTest
extends GdUnitTestSuite

func test_player_hand_counter_increases_after_draw_card():
	var deck_scene = preload("res://src/Scenes/Cards/deck.tscn").instantiate()
	add_child(deck_scene)
	var player_hand_scene = preload("res://src/Scenes/GUI/components/PlayerHand.tscn")
	var player_hand = player_hand_scene.instantiate()
	add_child(player_hand)
	
	deck_scene.connect("update_player_hand", Callable(player_hand, "add_card_to_hand"))
	
	deck_scene._ready()
	player_hand._ready()
	
	# comprar 2 cartas
	deck_scene.draw_card()
	deck_scene.draw_card()
	
	await get_tree().process_frame
	
	var player_hand_count = 0
	
	for i in player_hand.player_hand.keys():
		player_hand_count += player_hand.player_hand[i]["count"]
	
	assert_that(player_hand_count).is_equal(2)

func test_draw_card_should_remove_one_card_from_deck():
	var deck_scene = preload("res://src/Scenes/Cards/deck.tscn").instantiate()
	add_child(deck_scene)
	deck_scene._ready()
	var initial_size = deck_scene.player_deck.size()
	deck_scene.draw_card()
	assert_that(deck_scene.player_deck.size()).is_equal(initial_size - 1)
