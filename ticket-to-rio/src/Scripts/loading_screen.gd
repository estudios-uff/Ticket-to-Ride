extends Control

var scene = "res://src/Scenes/tutorialTest.tscn"

func _ready() -> void:
	ResourceLoader.load_threaded_request(scene)
	
func _process(delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(scene, progress)
	$ProgressBar.value = progress[0]*100
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(scene)
		get_tree().change_scene_to_packed(packed_scene)
