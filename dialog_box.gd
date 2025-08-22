# DialogSystem.gd
extends CanvasLayer

@onready var dialog_box = $DialogBox
@onready var panel = $DialogBox/Panel
@onready var text_label = $DialogBox/Panel/Text
@onready var choices_container = $DialogBox/Panel/Choices
@onready var time_bar = $DialogBox/Panel/TimeBar
@onready var bleep_audio = $DialogBox/Panel/Bleep

var current_dialog = []
var current_index = 0
var is_typing = false
var typing_speed = 0.03
var choice_time_limit = 5.0
var current_timer = 0.0

signal dialog_finished
signal choice_selected(choice_index: int)

func _ready():
	hide_dialog()
	time_bar.visible = false

func _input(event):
	if not dialog_box.visible:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if is_typing:
			# Skip typing animation
			complete_current_text()
		elif choices_container.get_child_count() == 0:
			# No choices, advance dialog
			advance_dialog()

func _process(delta):
	if time_bar.visible and current_timer > 0:
		current_timer -= delta
		time_bar.value = (current_timer / choice_time_limit) * 100
		
		if current_timer <= 0:
			# Time up, select first choice or advance
			if choices_container.get_child_count() > 0:
				select_choice(0)
			else:
				advance_dialog()

# Main function to start a dialog sequence
func start_dialog(dialog_data: Array):
	current_dialog = dialog_data
	current_index = 0
	show_dialog()
	display_current_dialog()

func show_dialog():
	dialog_box.visible = true
	# Add slide-in animation if desired
	var tween = create_tween()
	dialog_box.modulate.a = 0
	tween.tween_property(dialog_box, "modulate:a", 1.0, 0.3)

func hide_dialog():
	dialog_box.visible = false
	clear_choices()
	time_bar.visible = false
	current_timer = 0

func display_current_dialog():
	if current_index >= current_dialog.size():
		finish_dialog()
		return
		
	var dialog_item = current_dialog[current_index]
	
	# Clear previous choices
	clear_choices()
	time_bar.visible = false
	
	# Display text with typing effect
	if dialog_item.has("text"):
		type_text(dialog_item.text)
	
	# Handle choices
	if dialog_item.has("choices"):
		# Wait for typing to finish before showing choices
		await text_typing_finished
		show_choices(dialog_item.choices)
		
		# Start timer if specified
		if dialog_item.has("time_limit"):
			start_choice_timer(dialog_item.time_limit)

func type_text(text: String):
	is_typing = true
	text_label.text = ""
	text_label.visible_characters = 0
	
	# Set full text for proper sizing
	text_label.text = text
	
	# Animate character by character
	var tween = create_tween()
	tween.tween_method(update_visible_characters, 0, text.length(), text.length() * typing_speed)
	await tween.finished
	
	is_typing = false
	text_typing_finished.emit()

signal text_typing_finished

func update_visible_characters(count: int):
	text_label.visible_characters = count
	
	# Play bleep sound occasionally
	if count % 2 == 0 and bleep_audio:
		bleep_audio.play()

func complete_current_text():
	if is_typing:
		# Stop any running tweens
		var tweens = get_tree().get_processed_tweens()
		for tween in tweens:
			if tween.get_valid():
				tween.kill()
		
		# Show full text immediately
		text_label.visible_characters = text_label.text.length()
		is_typing = false
		text_typing_finished.emit()

func show_choices(choices: Array):
	for i in range(choices.size()):
		var choice_button = Button.new()
		choice_button.text = choices[i].text
		choice_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice_button.add_theme_stylebox_override("normal", create_choice_style())
		choice_button.add_theme_stylebox_override("hover", create_choice_hover_style())
		choice_button.add_theme_color_override("font_color", Color.WHITE)
		choice_button.add_theme_color_override("font_hover_color", Color.YELLOW)
		
		choice_button.pressed.connect(func(): select_choice(i))
		choices_container.add_child(choice_button)

func create_choice_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.border_width_left = 2
	style.border_color = Color.WHITE
	return style

func create_choice_hover_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.1)
	style.border_width_left = 2
	style.border_color = Color.YELLOW
	return style

func start_choice_timer(time_limit: float):
	choice_time_limit = time_limit
	current_timer = time_limit
	time_bar.visible = true
	time_bar.max_value = 100

func select_choice(choice_index: int):
	var dialog_item = current_dialog[current_index]
	var selected_choice = dialog_item.choices[choice_index]
	
	time_bar.visible = false
	current_timer = 0
	
	choice_selected.emit(choice_index)
	
	# Handle choice consequences
	if selected_choice.has("next_dialog"):
		current_dialog = selected_choice.next_dialog
		current_index = 0
		display_current_dialog()
	elif selected_choice.has("jump_to"):
		current_index = selected_choice.jump_to
		display_current_dialog()
	else:
		advance_dialog()

func clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func advance_dialog():
	current_index += 1
	display_current_dialog()

func finish_dialog():
	hide_dialog()
	dialog_finished.emit()

# Example dialog data structure
func get_example_dialog() -> Array:
	return [
		{
			"text": "[color=red]Shut up and give me my shot.[/color]",
		},
		{
			"text": "Listen, I understand your pain. We are the same far below. Until closer to fighting again than I'm glad to.",
		},
		{
			"text": "We don't need to be someone. We can work together.",
		},
		{
			"text": "Ooh. I [color=yellow]LOVE[/color] anime! Who are you supposed to be?",
			"choices": [
				{
					"text": "Obviously Shinju Sakamura from Ex Vs X - Sakura reDUX 2.",
				},
				{
					"text": "I'm not cosplaying anything.",
				},
				{
					"text": "None of your business.",
				}
			],
			"time_limit": 5.0
		}
	]
