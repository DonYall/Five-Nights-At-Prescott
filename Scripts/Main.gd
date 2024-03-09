extends Node

var electricity = true
var riyyan_min_temperature = randf_range(18, 19)
var temp = 21
var gameOverScene

# Called when the node enters the scene tree for the first time.
func _ready():
	$OfficeArea/ElectricityButton.pressed.connect(_on_electricity_button_pressed)
	$OfficeArea.died_to_hashir.connect(game_over.bind("hashir"))
	$PramitMovementTimer.start(randi_range(10, 20))
	$DonActiveTimer.start(randi_range(10, 30))
	$GameTimer.start(180)
	gameOverScene = preload("res://Scenes/GameOver.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(get_children()) <= 1:
		return
	if not electricity:
		temp -= delta
		if temp <= riyyan_min_temperature:
			temp = riyyan_min_temperature
			game_over("riyyan")
		$OfficeArea/Office/RiyyanAtDoor.visible = true
	else:
		$OfficeArea/Office/RiyyanAtDoor.visible = false

	var time = int(6 - $GameTimer.time_left / 30)
	if time == 0:
		time = 12
	var mohamed_happiness = 2 - \
	(1 if $OfficeArea/Monitor/Cameras/Mohamed/MohamedWake.volume_db > -10 else 0) - \
	(1 if $OfficeArea/HashirWake.playing else 0) - \
	(1 if $OfficeArea/DonScream.playing else 0)
	if mohamed_happiness <= 0:
		$OfficeArea/Office/MohamedAtDoor.visible = true
		if $MohamedKillTimer.is_stopped():
			$MohamedKillTimer.start(15)
	elif mohamed_happiness == 2:
		if $MohamedQuietTimer.is_stopped():
			$OfficeArea/Office/MohamedAtDoor.visible = true
			$MohamedQuietTimer.start(randi_range(5, 10))
	elif $MohamedKillTimer.is_stopped():
		$MohamedQuietTimer.stop()
		$OfficeArea/Office/MohamedAtDoor.visible = false
	else:
		$OfficeArea/Office/MohamedAtDoor.visible = true

	$HUD/TemperatureLabel.text = str(snapped(temp, 0.1)) + "°C "
	$HUD/TimeLabel.text = str(time) + "AM "
	$HUD/SoundMeter.value = 100 * (2 - mohamed_happiness) / 3

	# DEBUG STATS
	$HUD/DebugStats/TimeLeft.text = "Time: " + str($GameTimer.time_left)
	$HUD/DebugStats/NextPramitMovement.text = "Pramit: " + str($PramitMovementTimer.time_left)
	$HUD/DebugStats/MohamedHappiness.text = "Sound : " + str(2 - mohamed_happiness)
	if !$MohamedKillTimer.is_stopped():
		$HUD/DebugStats/MohamedKill.text = "Mohamed: " + str($MohamedKillTimer.time_left)
	$HUD/DebugStats/MohamedQuiet.text = "Mohamed Quiet: " + str($MohamedQuietTimer.time_left)
	$HUD/DebugStats/PramitPosition.text = "Pramit pos: " + str($OfficeArea.pramit_position)
	$HUD/DebugStats/NextDonActive.text = "Don active: " + str($DonActiveTimer.time_left)
	$HUD/DebugStats/NextDonScream.text = "Don scream: " + str($DonScreamTimer.time_left)

func _on_pramit_movement_timer_timeout():
	if $OfficeArea.pramit_position == 0:
		if not $OfficeArea.is_looking_at_pramit():
			game_over("pramit")
		else:
			$OfficeArea.pramit_position = 4
	$OfficeArea.pramit_timeout()
	$PramitMovementTimer.start(randi_range(10, 20))

func _on_don_scream_timer_timeout():
	$OfficeArea/DonScream.play()
	$DonScreamTimer.start(randi_range(0, 10))

func _on_mohamed_kill_timer_timeout():
	game_over("mohamed")

func _on_don_active_timer_timeout():
	if not $OfficeArea.don_active:
		$OfficeArea.don_active = true
		$OfficeArea/Monitor/Cameras/Don/DonEmpty.visible = false
		$DonScreamTimer.start(randi_range(5, 10))

func _on_electricity_button_pressed():
	$OfficeArea/ElectricitySound.play()
	if $OfficeArea.hashir_is_active():
		game_over("hashir")
	electricity = !electricity
	if electricity and $DonActiveTimer.is_stopped():
		$DonActiveTimer.start(randi_range(10, 40))
	elif $OfficeArea.don_active:
		$DonActiveTimer.stop()
		$DonScreamTimer.stop()
		$OfficeArea.don_active = false
		$OfficeArea/Monitor/Cameras/Don/DonEmpty.visible = true	
	$OfficeArea/Office.texture = $OfficeArea/OfficeNormal.texture if electricity else $OfficeArea/OfficeDark.texture

func _on_mohamed_quiet_timer_timeout():
	game_over("mohamed")

func game_over(died_by):
	print("game over. you died to " + died_by)
	for child in get_children():
		if not child.get_name() == "GameOver":
			child.queue_free()
	$GameOver.visible = true
	$GameOver/Label.text = "game over - " + died_by

func _on_hashir_alarm_timer_timeout():
	$OfficeArea/HashirWake.play()
