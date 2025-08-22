extends Area2D

var dialogue_active = false

func _physics_process(delta):
	if dialogue_active:
		return

	var bodies = get_overlapping_bodies()
	for body in bodies:
		dialogue_active = true
		var dialogue = load("res://secound.dialogue")
		DialogueManager.show_example_dialogue_balloon(dialogue)
		
		# Connect the "dialogue_finished" signal to resume interaction after it's done
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		break

func _on_dialogue_finished():
	dialogue_active = false
