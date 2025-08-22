extends Area2D

@export var dialog_text: String = "Ooh, I [color=yellow]LOVE[/color] anime! Who are you supposed to be?"
@export_node_path var dialog_box_path: NodePath

var triggered := false

func _on_body_entered(body: Node) -> void:
	if triggered: return
	if body.is_in_group("player"):   # add your player to group
		triggered = true
		var box = get_node(dialog_box_path) as Control
		await box.say(dialog_text)
		# after line ends you can wait for input/choices
