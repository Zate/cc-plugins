---
allowed_tools:
  - AskUserQuestion
  - mcp__godot__*
  - Write
  - Read
  - Skill
---

Create a quick UI template for common game UI screens.

# Process

1. **Ask the user what type of UI they want to create:**

Use AskUserQuestion with the following options:

Question: "What type of UI screen would you like to create?"
Header: "UI Type"
Multi-select: false
Options:
- Main Menu: Title screen with New Game, Continue, Settings, Quit
- Pause Menu: In-game pause screen with Resume, Settings, Main Menu, Quit
- Settings Menu: Graphics, audio, and gameplay settings with tabs
- Game HUD: Health bar, score, and interactive buttons
- Inventory: Grid-based item management system
- Dialogue Box: Character dialogue with portrait and choices
- Confirmation Dialog: Yes/No popup dialog

Question 2: "Where should the UI scene be created?"
Header: "Location"
Multi-select: false
Options:
- scenes/ui/menus/: For menu screens
- scenes/ui/hud/: For in-game HUD elements
- scenes/ui/dialogs/: For popup dialogs
- Custom path: I'll specify the path

2. **If Custom path selected, ask for the specific path**

3. **Create the appropriate template based on selection**

## Main Menu Template

Create scene with:
```
CanvasLayer (root)
├── ColorRect (background - full rect anchors)
├── MarginContainer (full rect, margins: 40px all sides)
│   └── VBoxContainer (alignment: center)
│       ├── Control (spacer - custom_minimum_size.y = 100)
│       ├── Label (title - custom font size 48, center aligned)
│       ├── Control (spacer - custom_minimum_size.y = 50)
│       ├── VBoxContainer (button_container - separation: 10)
│       │   ├── Button (new_game_btn - text: "New Game", custom_minimum_size.x = 200)
│       │   ├── Button (continue_btn - text: "Continue", custom_minimum_size.x = 200)
│       │   ├── Button (settings_btn - text: "Settings", custom_minimum_size.x = 200)
│       │   └── Button (quit_btn - text: "Quit", custom_minimum_size.x = 200)
│       └── Control (spacer with size_flags_vertical = 3)
```

Create accompanying script:
```gdscript
extends CanvasLayer

@onready var new_game_btn = $MarginContainer/VBoxContainer/VBoxContainer/new_game_btn
@onready var continue_btn = $MarginContainer/VBoxContainer/VBoxContainer/continue_btn
@onready var settings_btn = $MarginContainer/VBoxContainer/VBoxContainer/settings_btn
@onready var quit_btn = $MarginContainer/VBoxContainer/VBoxContainer/quit_btn

func _ready():
	# Connect button signals
	new_game_btn.pressed.connect(_on_new_game_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Set focus for gamepad support
	new_game_btn.grab_focus()

	# Check if save exists for continue button
	continue_btn.disabled = not _has_save_file()

	# Fade in animation
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func _has_save_file() -> bool:
	# TODO: Implement save file checking
	return FileAccess.file_exists("user://savegame.save")

func _on_new_game_pressed():
	# TODO: Implement new game logic
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_continue_pressed():
	# TODO: Implement load game logic
	pass

func _on_settings_pressed():
	# TODO: Open settings menu
	get_tree().change_scene_to_file("res://scenes/ui/menus/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()
```

## Pause Menu Template

Create scene with:
```
CanvasLayer (root - layer: 100)
├── ColorRect (overlay - full rect, color: #00000080, mouse_filter: STOP)
├── CenterContainer (full rect anchors)
│   └── PanelContainer (custom_minimum_size: 400x500)
│       └── MarginContainer (margins: 20px all sides)
│           └── VBoxContainer (separation: 15)
│               ├── Label (title - text: "PAUSED", align: center, font size: 36)
│               ├── Control (spacer - custom_minimum_size.y = 20)
│               ├── Button (resume_btn - text: "Resume")
│               ├── Button (settings_btn - text: "Settings")
│               ├── Button (main_menu_btn - text: "Main Menu")
│               └── Button (quit_btn - text: "Quit")
```

Create accompanying script:
```gdscript
extends CanvasLayer

@onready var resume_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/resume_btn
@onready var settings_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/settings_btn
@onready var main_menu_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/main_menu_btn
@onready var quit_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/quit_btn

func _ready():
	# Connect signals
	resume_btn.pressed.connect(_on_resume_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

	# Pause the game
	get_tree().paused = true

	# Set focus
	resume_btn.grab_focus()

	# Pop-up animation
	$CenterContainer.scale = Vector2(0.8, 0.8)
	$CenterContainer.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($CenterContainer, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($CenterContainer, "modulate:a", 1.0, 0.3)

func _on_resume_pressed():
	_close_menu()

func _on_settings_pressed():
	# TODO: Open settings submenu
	pass

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menus/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _close_menu():
	get_tree().paused = false
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_close_menu()
```

## Settings Menu Template

Create scene with:
```
CanvasLayer (root)
├── ColorRect (background - full rect)
├── MarginContainer (full rect, margins: 40px all sides)
│   └── VBoxContainer (separation: 20)
│       ├── Label (title - text: "Settings", font size: 36)
│       ├── TabContainer (size_flags_vertical: 3)
│       │   ├── VBoxContainer (name: "Graphics", separation: 10)
│       │   │   ├── HBoxContainer
│       │   │   │   ├── Label (text: "Resolution:")
│       │   │   │   ├── Control (size_flags_horizontal: 3)
│       │   │   │   └── OptionButton (resolution_option)
│       │   │   ├── HBoxContainer
│       │   │   │   ├── Label (text: "Fullscreen:")
│       │   │   │   ├── Control (size_flags_horizontal: 3)
│       │   │   │   └── CheckBox (fullscreen_check)
│       │   │   └── HBoxContainer
│       │   │       ├── Label (text: "VSync:")
│       │   │       ├── Control (size_flags_horizontal: 3)
│       │   │       └── CheckBox (vsync_check)
│       │   └── VBoxContainer (name: "Audio", separation: 10)
│       │       ├── HBoxContainer
│       │       │   ├── Label (text: "Master Volume:")
│       │       │   └── HSlider (master_slider - min: 0, max: 100, value: 100)
│       │       ├── HBoxContainer
│       │       │   ├── Label (text: "Music Volume:")
│       │       │   └── HSlider (music_slider - min: 0, max: 100, value: 100)
│       │       └── HBoxContainer
│       │           ├── Label (text: "SFX Volume:")
│       │           └── HSlider (sfx_slider - min: 0, max: 100, value: 100)
│       └── HBoxContainer (separation: 10)
│           ├── Control (size_flags_horizontal: 3)
│           ├── Button (apply_btn - text: "Apply")
│           └── Button (back_btn - text: "Back")
```

Create accompanying script:
```gdscript
extends CanvasLayer

# Graphics tab
@onready var resolution_option = $MarginContainer/VBoxContainer/TabContainer/Graphics/HBoxContainer/resolution_option
@onready var fullscreen_check = $MarginContainer/VBoxContainer/TabContainer/Graphics/HBoxContainer2/fullscreen_check
@onready var vsync_check = $MarginContainer/VBoxContainer/TabContainer/Graphics/HBoxContainer3/vsync_check

# Audio tab
@onready var master_slider = $MarginContainer/VBoxContainer/TabContainer/Audio/HBoxContainer/master_slider
@onready var music_slider = $MarginContainer/VBoxContainer/TabContainer/Audio/HBoxContainer2/music_slider
@onready var sfx_slider = $MarginContainer/VBoxContainer/TabContainer/Audio/HBoxContainer3/sfx_slider

# Buttons
@onready var apply_btn = $MarginContainer/VBoxContainer/HBoxContainer/apply_btn
@onready var back_btn = $MarginContainer/VBoxContainer/HBoxContainer/back_btn

func _ready():
	# Populate resolution options
	resolution_option.add_item("1920x1080")
	resolution_option.add_item("1280x720")
	resolution_option.add_item("1024x768")

	# Load current settings
	_load_settings()

	# Connect signals
	apply_btn.pressed.connect(_on_apply_pressed)
	back_btn.pressed.connect(_on_back_pressed)

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _load_settings():
	# TODO: Load from config file
	fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	vsync_check.button_pressed = (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED)

func _on_apply_pressed():
	_save_settings()

func _save_settings():
	# Graphics settings
	if fullscreen_check.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if vsync_check.button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# TODO: Save to config file
	# TODO: Apply resolution

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/menus/main_menu.tscn")

func _on_master_volume_changed(value: float):
	# TODO: Apply to audio bus
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))

func _on_music_volume_changed(value: float):
	# TODO: Apply to audio bus
	pass

func _on_sfx_volume_changed(value: float):
	# TODO: Apply to audio bus
	pass
```

## Game HUD Template

Create scene with:
```
CanvasLayer (root - layer: 10)
├── MarginContainer (full rect, margins: 20px all sides)
│   └── VBoxContainer
│       ├── HBoxContainer (top_bar - separation: 10)
│       │   ├── TextureRect (health_icon - expand_mode: keep_size, custom_minimum_size: 32x32)
│       │   ├── ProgressBar (health_bar - custom_minimum_size: 200x24)
│       │   ├── Control (spacer - size_flags_horizontal: 3)
│       │   ├── Label (score_label - text: "Score: 0")
│       │   └── TextureRect (coin_icon - expand_mode: keep_size, custom_minimum_size: 24x24)
│       ├── Control (middle_spacer - size_flags_vertical: 3)
│       └── HBoxContainer (bottom_bar - separation: 10)
│           ├── Control (spacer - size_flags_horizontal: 3)
│           ├── TextureButton (inventory_btn - custom_minimum_size: 48x48)
│           ├── TextureButton (map_btn - custom_minimum_size: 48x48)
│           └── TextureButton (pause_btn - custom_minimum_size: 48x48)
```

Create accompanying script:
```gdscript
extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/HBoxContainer/health_bar
@onready var score_label = $MarginContainer/VBoxContainer/HBoxContainer/score_label
@onready var inventory_btn = $MarginContainer/VBoxContainer/HBoxContainer2/inventory_btn
@onready var map_btn = $MarginContainer/VBoxContainer/HBoxContainer2/map_btn
@onready var pause_btn = $MarginContainer/VBoxContainer/HBoxContainer2/pause_btn

var current_score: int = 0

func _ready():
	# Connect button signals
	inventory_btn.pressed.connect(_on_inventory_pressed)
	map_btn.pressed.connect(_on_map_pressed)
	pause_btn.pressed.connect(_on_pause_pressed)

	# Initialize health bar
	health_bar.max_value = 100
	health_bar.value = 100

func set_health(value: float):
	var tween = create_tween()
	tween.tween_property(health_bar, "value", value, 0.3)

	# Change color based on health
	if value < 30:
		health_bar.modulate = Color.RED
	elif value < 60:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.GREEN

func add_score(amount: int):
	current_score += amount
	score_label.text = "Score: %d" % current_score

	# Bounce animation
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.1)

func _on_inventory_pressed():
	# TODO: Open inventory
	pass

func _on_map_pressed():
	# TODO: Open map
	pass

func _on_pause_pressed():
	# Open pause menu
	var pause_scene = load("res://scenes/ui/menus/pause_menu.tscn")
	get_tree().root.add_child(pause_scene.instantiate())
```

## Inventory Template

Create scene with:
```
CanvasLayer (root - layer: 50)
├── ColorRect (overlay - full rect, color: #00000080)
├── CenterContainer (full rect)
│   └── PanelContainer (custom_minimum_size: 800x600)
│       └── MarginContainer (margins: 20px all sides)
│           └── VBoxContainer (separation: 15)
│               ├── Label (title - text: "Inventory", font size: 32)
│               ├── HSeparator
│               ├── HBoxContainer (size_flags_vertical: 3, separation: 15)
│               │   ├── ScrollContainer (size_flags_horizontal: 3)
│               │   │   └── GridContainer (item_grid - columns: 5, separation: 10)
│               │   └── PanelContainer (item_details - custom_minimum_size.x: 250)
│               │       └── MarginContainer (margins: 10px all sides)
│               │           └── VBoxContainer
│               │               ├── TextureRect (item_image - expand_mode: keep_aspect_centered, custom_minimum_size: 200x200)
│               │               ├── Label (item_name - text: "Select an item", align: center, font size: 18)
│               │               ├── RichTextLabel (item_description - text: "No item selected", bbcode_enabled: true, size_flags_vertical: 3)
│               │               └── Button (use_btn - text: "Use", disabled: true)
│               └── Button (close_btn - text: "Close")
```

Create accompanying script:
```gdscript
extends CanvasLayer

@onready var item_grid = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/item_grid
@onready var item_image = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/item_image
@onready var item_name = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/item_name
@onready var item_description = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/item_description
@onready var use_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/use_btn
@onready var close_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/close_btn

var selected_item = null
const SLOT_SCENE = preload("res://scenes/ui/hud/hud_components/inventory_slot.tscn")

func _ready():
	# Connect signals
	use_btn.pressed.connect(_on_use_pressed)
	close_btn.pressed.connect(_on_close_pressed)

	# Populate inventory
	_populate_inventory()

	# Pause game
	get_tree().paused = true

func _populate_inventory():
	# Clear existing slots
	for child in item_grid.get_children():
		child.queue_free()

	# TODO: Get inventory from inventory manager
	# For now, create empty slots
	for i in range(20):
		var slot = SLOT_SCENE.instantiate()
		slot.slot_clicked.connect(_on_slot_clicked.bind(slot))
		item_grid.add_child(slot)

func _on_slot_clicked(slot):
	# Update item details
	if slot.item_data:
		selected_item = slot.item_data
		item_name.text = slot.item_data.name
		item_description.text = slot.item_data.description
		item_image.texture = slot.item_data.icon
		use_btn.disabled = false
	else:
		selected_item = null
		item_name.text = "Empty slot"
		item_description.text = ""
		item_image.texture = null
		use_btn.disabled = true

func _on_use_pressed():
	if selected_item:
		# TODO: Use item logic
		pass

func _on_close_pressed():
	get_tree().paused = false
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
```

## Dialogue Box Template

Create scene with:
```
CanvasLayer (root - layer: 20)
├── Control (spacer - size_flags_vertical: 3)
└── PanelContainer (dialogue_panel - anchor_left: 0, anchor_right: 1, anchor_bottom: 1, custom_minimum_size.y: 200)
    └── MarginContainer (margins: 15px all sides)
        └── VBoxContainer (separation: 10)
            ├── HBoxContainer (character_info - separation: 10)
            │   ├── TextureRect (portrait - expand_mode: keep_size, custom_minimum_size: 80x80)
            │   └── Label (character_name - text: "Character", font size: 20)
            ├── RichTextLabel (dialogue_text - bbcode_enabled: true, size_flags_vertical: 3, text: "Dialogue text goes here...")
            └── VBoxContainer (choices_container - separation: 5)
```

Create accompanying script:
```gdscript
extends CanvasLayer

@onready var portrait = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/portrait
@onready var character_name = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/character_name
@onready var dialogue_text = $PanelContainer/MarginContainer/VBoxContainer/dialogue_text
@onready var choices_container = $PanelContainer/MarginContainer/VBoxContainer/choices_container

var current_dialogue_index: int = 0
var dialogue_data: Array = []
var text_speed: float = 0.05
var is_text_complete: bool = false

func _ready():
	# Hide initially
	$PanelContainer.modulate.a = 0
	$PanelContainer.position.y = 50

func show_dialogue(data: Array):
	dialogue_data = data
	current_dialogue_index = 0
	_display_current_dialogue()

	# Slide in animation
	var tween = create_tween()
	tween.tween_property($PanelContainer, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property($PanelContainer, "position:y", 0, 0.3)

func _display_current_dialogue():
	if current_dialogue_index >= dialogue_data.size():
		_close_dialogue()
		return

	var dialogue = dialogue_data[current_dialogue_index]

	# Set character info
	character_name.text = dialogue.get("character", "")
	if dialogue.has("portrait"):
		portrait.texture = dialogue.portrait

	# Clear choices
	for child in choices_container.get_children():
		child.queue_free()

	# Animate text
	is_text_complete = false
	_type_text(dialogue.text)

	# Add choices if present
	if dialogue.has("choices") and dialogue.choices.size() > 0:
		await get_tree().create_timer(0.1).timeout  # Wait for text to start
		for i in range(dialogue.choices.size()):
			var choice_text = dialogue.choices[i]
			var btn = Button.new()
			btn.text = choice_text
			btn.pressed.connect(_on_choice_selected.bind(i))
			choices_container.add_child(btn)

func _type_text(text: String):
	dialogue_text.text = ""
	dialogue_text.visible_characters = 0
	dialogue_text.text = text

	var char_count = text.length()
	for i in range(char_count + 1):
		dialogue_text.visible_characters = i
		await get_tree().create_timer(text_speed).timeout

	is_text_complete = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_text_complete and choices_container.get_child_count() == 0:
			_next_dialogue()
		elif not is_text_complete:
			# Skip text animation
			dialogue_text.visible_ratio = 1.0
			is_text_complete = true

func _next_dialogue():
	current_dialogue_index += 1
	_display_current_dialogue()

func _on_choice_selected(choice_index: int):
	# TODO: Handle dialogue choice
	# For now, just advance
	_next_dialogue()

func _close_dialogue():
	var tween = create_tween()
	tween.tween_property($PanelContainer, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property($PanelContainer, "position:y", 50, 0.3)
	tween.tween_callback(queue_free)
```

## Confirmation Dialog Template

Create scene with:
```
CanvasLayer (root - layer: 200)
├── ColorRect (overlay - full rect, color: #00000080)
├── CenterContainer (full rect)
│   └── PanelContainer (custom_minimum_size: 400x200)
│       └── MarginContainer (margins: 20px all sides)
│           └── VBoxContainer (separation: 20)
│               ├── Label (message - text: "Are you sure?", align: center, autowrap: true, size_flags_vertical: 3)
│               └── HBoxContainer (separation: 10)
│                   ├── Button (cancel_btn - text: "Cancel", size_flags_horizontal: 3)
│                   └── Button (confirm_btn - text: "Confirm", size_flags_horizontal: 3)
```

Create accompanying script:
```gdscript
extends CanvasLayer

signal confirmed
signal cancelled

@onready var message = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/message
@onready var cancel_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/cancel_btn
@onready var confirm_btn = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/confirm_btn

func _ready():
	# Connect signals
	cancel_btn.pressed.connect(_on_cancel_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)

	# Set focus
	cancel_btn.grab_focus()

	# Pop-up animation
	$CenterContainer.scale = Vector2(0.8, 0.8)
	$CenterContainer.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($CenterContainer, "scale", Vector2.ONE, 0.2)
	tween.parallel().tween_property($CenterContainer, "modulate:a", 1.0, 0.2)

func set_message(text: String):
	message.text = text

func _on_confirm_pressed():
	confirmed.emit()
	queue_free()

func _on_cancel_pressed():
	cancelled.emit()
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
```

# After Creating Template

After creating the selected template:

1. Inform the user of the files created:
   - Scene file location
   - Script file location

2. Provide next steps:
   - "The [template name] has been created at [path]"
   - "You can customize the appearance by:"
     - Creating a theme resource
     - Adjusting colors, fonts, and spacing
     - Adding custom textures/icons
   - "To use this UI:"
     - [Specific usage instructions for the template]
   - "For more advanced UI customization, you can invoke the godot-ui skill or ask me for help!"

3. Offer to:
   - Create additional related scenes (e.g., "Would you like me to create the inventory slot component as well?")
   - Set up theme resources
   - Add more features to the template
