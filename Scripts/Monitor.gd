extends Node2D

var selected_camera
signal toggle_audio

# Called when the node enters the scene tree for the first time.
func _ready():
	selected_camera = $Cameras/Hallway

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_selected_camera(new_selected_camera):
	for camera in $Cameras.get_children():
		camera.visible = false
	selected_camera = new_selected_camera
	selected_camera.visible = true

func _on_toggle_mohamed_pressed():
	change_selected_camera($Cameras/Mohamed)

func _on_toggle_hashir_pressed():
	pass # Replace with function body.

func _on_toggle_don_pressed():
	change_selected_camera($Cameras/Don)

func _on_toggle_riyyan_pressed():
	pass # Replace with function body.

func _on_toggle_hallway_pressed():
	change_selected_camera($Cameras/Hallway)

func _on_audio_button_pressed():
	if $Cameras/Mohamed/MohamedWake.volume_db == -10:
		$Cameras/Mohamed/MohamedWake.volume_db = 0
		$Cameras/Mohamed/AudioButton.text = "decrease volume"
	else:
		$Cameras/Mohamed/MohamedWake.volume_db = -10
		$Cameras/Mohamed/AudioButton.text = "increase volume"
