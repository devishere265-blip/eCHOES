extends Control

class_name QuestionUI

@onready var question_label = $Panel/VBoxContainer/QuestionLabel
@onready var character_name_label = $Panel/VBoxContainer/CharacterNameLabel
@onready var panel = $Panel
@onready var animation_player = $AnimationPlayer

var current_character: QuestioningCharacter
var display_duration = 4.0

func _ready():
	panel.modulate.a = 0.0
	connect_to_questioning_characters()

func connect_to_questioning_characters():
	# Connect to all QuestioningCharacter nodes in the scene
	var characters = get_tree().get_nodes_in_group("questioning_characters")
	for character in characters:
		if character.has_signal("question_asked"):
			character.question_asked.connect(_on_question_asked)

func _on_question_asked(question: String, character: QuestioningCharacter):
	display_question(question, character)

func display_question(question: String, character: QuestioningCharacter):
	current_character = character
	question_label.text = question
	character_name_label.text = character.name if character.name else "Mysterious Figure"
	
	show_question_panel()

func show_question_panel():
	# Fade in animation
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	# Auto-hide after duration
	await get_tree().create_timer(display_duration).timeout
	hide_question_panel()

func hide_question_panel():
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.3)

func _input(event):
	# Optional: Hide panel when player presses a key
	if event.is_pressed() and panel.modulate.a > 0.5:
		hide_question_panel()
