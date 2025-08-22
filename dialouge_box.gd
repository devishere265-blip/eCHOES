extends Control

var dialogues: Array = []
var current_index: int = 0

@onready var label = $Panel/Label

func start_dialogue(new_dialogues: Array):
	dialogues = new_dialogues
	current_index = 0
	show()
	show_dialogue()

func show_dialogue():
	if current_index < dialogues.size():
		label.text = dialogues[current_index]
	else:
		hide() # Hide when finished

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and visible:
		current_index += 1
		show_dialogue()
