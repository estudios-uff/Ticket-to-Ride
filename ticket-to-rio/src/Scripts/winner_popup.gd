extends PanelContainer

@onready var results_label: RichTextLabel = $RichTextLabel

func show_results(message: String):
	results_label.text = message
	show()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Scenes/main_menu.tscn")
