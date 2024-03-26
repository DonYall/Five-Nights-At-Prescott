extends TextureRect

var main_scene
var night5_scene
var button_hover_theme
var button_unhover_theme

# Called when the node enters the scene tree for the first time.
func _ready():
	main_scene = preload("res://Scenes/Main.tscn")
	night5_scene = preload("res://Scenes/Night5.tscn")
	var font = load("res://Assets/Fonts/DoubleHomicide.ttf")
	button_hover_theme = Theme.new()
	button_hover_theme.set_color("white", "button", Color.WHITE)
	button_hover_theme.set_font("homicide", "button", font)
	button_hover_theme.set_font_size("homicide", "button", 70)
	button_unhover_theme = Theme.new()
	button_unhover_theme.set_color("white", "button", Color.GRAY)
	button_unhover_theme.set_font("homicide", "button", font)
	button_hover_theme.set_font_size("homicide", "button", 70)
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		button.connect("mouse_entered", mouse_entered_button.bind(button))
		button.connect("mouse_exited", mouse_exited_button.bind(button))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_night(night):
	var main_instance = main_scene.instantiate()
	add_child(main_instance)
	main_instance.init(night)
	visible = false
	$MenuMusic.stop()

func _on_night_1_pressed():
	init_night(1)

func _on_night_2_pressed():
	init_night(2)

func _on_night_3_pressed():
	init_night(3)

func _on_night_4_pressed():
	init_night(4)

func _on_night_5_pressed():
	var night5_instance = night5_scene.instantiate()
	add_child(night5_instance)
	visible = false
	$MenuMusic.stop()

func mouse_entered_button(button):
	button.get_child(0).visible = true
	button.set_theme(button_hover_theme)

func mouse_exited_button(button):
	button.get_child(0).visible = false
	button.set_theme(button_unhover_theme)

func _on_menu_music_finished():
	$MenuMusic.play()
