extends GdUnitTestSuite

const Global := preload("res://src/Scripts/Global/global.gd")

func test_global_initialization():
	var global = auto_free(Global.new())
	
	# Test initial properties
	assert_that(global.num_players).is_equal(1)
	assert_that(global.difficult).is_equal(0)
	assert_that(global.participants).is_not_null()
	assert_that(global.participants.size()).is_equal(0)

func test_global_color_values():
	var global = auto_free(Global.new())
	
	# Test that color values are correct
	assert_that(Global.AVAILABLE_COLORS["blue"]).is_equal(Color.SKY_BLUE)
	assert_that(Global.AVAILABLE_COLORS["green"]).is_equal(Color.LIME_GREEN)
	assert_that(Global.AVAILABLE_COLORS["yellow"]).is_equal(Color.YELLOW)
	assert_that(Global.AVAILABLE_COLORS["orange"]).is_equal(Color.DARK_ORANGE)
	assert_that(Global.AVAILABLE_COLORS["pink"]).is_equal(Color.DEEP_PINK)
	assert_that(Global.AVAILABLE_COLORS["red"]).is_equal(Color.RED)
	assert_that(Global.AVAILABLE_COLORS["gray"]).is_equal(Color.GRAY)
	assert_that(Global.AVAILABLE_COLORS["white"]).is_equal(Color.WHITE)

func test_get_participant_color_valid_participant():
	var global = auto_free(Global.new())
	
	# Setup participants
	global.assign_participant_colors(2, 1)
	
	# Test getting color for valid participants
	assert_that(global.get_participant_color(0)).is_equal(Color.SKY_BLUE)
	assert_that(global.get_participant_color(1)).is_equal(Color.LIME_GREEN)
	assert_that(global.get_participant_color("ia_0")).is_equal(Color.YELLOW)

func test_get_participant_color_invalid_participant():
	var global = auto_free(Global.new())
	
	# Test getting color for invalid participant
	assert_that(global.get_participant_color(999)).is_equal(Color.PURPLE)
	assert_that(global.get_participant_color("invalid_id")).is_equal(Color.PURPLE)
	assert_that(global.get_participant_color("")).is_equal(Color.PURPLE)

func test_get_participant_display_name_valid_participant():
	var global = auto_free(Global.new())
	
	# Setup participants
	global.assign_participant_colors(2, 1)
	
	# Test getting display name for valid participants
	assert_that(global.get_participant_display_name(0)).is_equal("Jogador 1")
	assert_that(global.get_participant_display_name(1)).is_equal("Jogador 2")
	assert_that(global.get_participant_display_name("ia_0")).is_equal("IA 0")

func test_get_participant_display_name_invalid_participant():
	var global = auto_free(Global.new())
	
	# Test getting display name for invalid participant
	assert_that(global.get_participant_display_name(999)).is_equal("Desconhecido")
	assert_that(global.get_participant_display_name("invalid_id")).is_equal("Desconhecido")
	assert_that(global.get_participant_display_name("")).is_equal("Desconhecido")

func test_player_display_name_format():
	var global = auto_free(Global.new())
	
	# Setup participants
	global.assign_participant_colors(3, 0)
	
	# Test that player display names follow the correct format
	assert_that(global.participants[0]["display_name"]).is_equal("Jogador 1")
	assert_that(global.participants[1]["display_name"]).is_equal("Jogador 2")
	assert_that(global.participants[2]["display_name"]).is_equal("Jogador 3")

func test_color_assignment_order():
	var global = auto_free(Global.new())
	
	# Setup participants
	global.assign_participant_colors(3, 2)
	
	# Test that colors are assigned in order
	var expected_colors = ["blue", "green", "yellow", "orange", "pink"]
	
	assert_that(global.participants[0]["color_name"]).is_equal(expected_colors[0])
	assert_that(global.participants[1]["color_name"]).is_equal(expected_colors[1])
	assert_that(global.participants[2]["color_name"]).is_equal(expected_colors[2])
	assert_that(global.participants["ia_0"]["color_name"]).is_equal(expected_colors[3])
	assert_that(global.participants["ia_1"]["color_name"]).is_equal(expected_colors[4])

func test_global_properties_modification():
	var global = auto_free(Global.new())
	
	# Test modifying num_players
	global.num_players = 5
	assert_that(global.num_players).is_equal(5)
	
	# Test modifying difficult
	global.difficult = 2
	assert_that(global.difficult).is_equal(2)

func test_participants_dictionary_operations():
	var global = auto_free(Global.new())
	
	# Test adding participants manually
	global.participants[0] = {
		"display_name": "Test Player",
		"color_name": "red",
		"color": Color.RED
	}
	
	assert_that(global.participants.size()).is_equal(1)
	assert_that(global.participants[0]["display_name"]).is_equal("Test Player") 
