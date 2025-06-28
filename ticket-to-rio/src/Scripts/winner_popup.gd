extends PanelContainer

@onready var results_label: RichTextLabel = $RichTextLabel

func show_results(message: String):
	results_label.text = message
	show()

func _on_ok_button_pressed():
	get_tree().quit()
