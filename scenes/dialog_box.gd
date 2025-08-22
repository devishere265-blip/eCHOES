extends Control

@export var chars_per_sec := 50.0
@onready var text: RichTextLabel = $Panel/Text
@onready var choices_box: VBoxContainer = $Panel/Choices
@onready var timebar: ProgressBar = $Panel/TimeBar


var _typing := false
var _skip := false
var _choice_pressed := -1

func _ready() -> void:
	visible = false
	text.visible_characters = 0
	modulate.a = 0.0   # start invisible

# ------------------ SHOW / HIDE ------------------

func popup_dialog() -> void:
	visible = true
	modulate.a = 0.0
	position.y = size.y   # start below screen
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	tw.tween_property(self, "position:y", size.y - 180, 0.3) # slide up

func hide_dialog() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	await tw.finished
	visible = false

# ------------------ SAY ------------------

func say(line: String) -> void:
	popup_dialog()
	text.bbcode_text = line
	text.visible_characters = 0
	_typing = true
	_skip = false

	while _typing and text.visible_characters < text.get_total_character_count():
		text.visible_characters += 1


		var step: float = 1.0 / max(chars_per_sec, 1.0)
		var t := 0.0
		while t < step:
			if _skip: break
			await get_tree().process_frame
			t += get_process_delta_time()

		if _skip:
			text.visible_characters = text.get_total_character_count()
			break

	_typing = false
	_skip = false
