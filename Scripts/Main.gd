extends Node

var gameOverScene
var electricity = true
var riyyan_min_temperature
var temp = 21

var pramit_movement_min
var pramit_movement_max

var don_active_min
var don_active_max

func init(night):
	if night == 1:
		riyyan_min_temperature = randf_range(18, 19)
		$OfficeArea.init(0.2)
		pramit_movement_min = 10
		pramit_movement_max = 20
		don_active_min = 20
		don_active_max = 30
	elif night == 2:
		riyyan_min_temperature = randf_range(19.5, 20)
		$OfficeArea.init(0.3)
		pramit_movement_min = 10
		pramit_movement_max = 20
		don_active_min = 10
		don_active_max = 30
	elif night == 3:
		riyyan_min_temperature = randf_range(20, 20.5)
		$OfficeArea.init(0.4)
		pramit_movement_min = 5
		pramit_movement_max = 15
		don_active_min = 10
		don_active_max = 20
	elif night == 4:
		riyyan_min_temperature = randf_range(20, 20.5)
		$OfficeArea.init(0.5)
		pramit_movement_min = 5
		pramit_movement_max = 10
		don_active_min = 10
		don_active_max = 20
	elif night == 5:
		riyyan_min_temperature = randf_range(20.4, 20.6)
		$OfficeArea.init(0.6)
		pramit_movement_min = 5
		pramit_movement_max = 10
		don_active_min = 10
		don_active_max = 15
	$OfficeArea/ElectricityButton.pressed.connect(_on_electricity_button_pressed)
	$OfficeArea.died_to_hashir.connect(game_over.bind("hashir"))
	$PramitMovementTimer.start(randi_range(pramit_movement_min, pramit_movement_max))
	$DonActiveTimer.start(randi_range(don_active_min, don_active_max))
	$GameTimer.start(180)

# Called when the node enters the scene tree for the first time.
func _ready():
	gameOverScene = preload("res://Scenes/GameOver.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(get_children()) < 11:
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
			$MohamedQuietTimer.start(randi_range(10, 15))
	elif $MohamedKillTimer.is_stopped():
		$MohamedQuietTimer.stop()
		$OfficeArea/Office/MohamedAtDoor.visible = false
	else:
		$OfficeArea/Office/MohamedAtDoor.visible = true

	$HUD/TemperatureLabel.text = str(snapped(temp, 0.1)) + "°C "
	$HUD/TimeLabel.text = str(time) + "AM "
	$HUD/SoundMeter.value = 100 * (2 - mohamed_happiness) / 3

	# DEBUG STATS
	if $HUD/DebugStats.visible:
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
	if $OfficeArea.pramit_position == 0 or $OfficeArea.pramit_position == 1 and $OfficeArea.is_looking_at_pramit():
		$OfficeArea.pramit_position = 4
	elif $OfficeArea.pramit_position == 0:
		game_over("pramit")
	$OfficeArea.pramit_timeout()
	$PramitMovementTimer.start(randi_range(pramit_movement_min, pramit_movement_max))

func _on_don_scream_timer_timeout():
	$OfficeArea/DonScream.play()
	$DonScreamTimer.start(randi_range(0, 10))

func _on_mohamed_kill_timer_timeout():
	game_over("mohamed")

func _on_don_active_timer_timeout():
	if not $OfficeArea.don_active:
		$OfficeArea.don_active = true
		$OfficeArea/Monitor/Cameras/Don/DonEmpty.visible = false
		$DonScreamTimer.start(randi_range(don_active_min - 5, don_active_max))

func _on_electricity_button_pressed():
	$OfficeArea/ElectricitySound.play()
	if $OfficeArea.hashir_is_active():
		game_over("hashir")
	electricity = !electricity
	if electricity and $DonActiveTimer.is_stopped():
		$DonActiveTimer.start(randi_range(don_active_min - 5, don_active_max))
	elif $OfficeArea.don_active:
		$DonActiveTimer.stop()
		$DonScreamTimer.stop()
		$OfficeArea.don_active = false
		$OfficeArea/Monitor/Cameras/Don/DonEmpty.visible = true	
	$OfficeArea/Office.texture = $OfficeArea/OfficeNormal.texture if electricity else $OfficeArea/OfficeDark.texture

func _on_mohamed_quiet_timer_timeout():
	game_over("mohamed")

func game_over(died_by):
	$GameTimer.stop()
	$DeathSound.play()
	print("game over: " + died_by)
	for child in get_children():
		if not (child.get_name() == "GameOver" or child.get_name() == "DeathSound"):
			child.queue_free()
	$GameOver.visible = true
	$GameOver/Label.text = "game over - " + died_by

func _on_hashir_alarm_timer_timeout():
	$TimerSound.play()

func _on_timer_sound_finished():
	$OfficeArea/HashirWake.play()
	$HashirAlarmTimer.start()

func _on_game_timer_timeout():
	game_over("you win!")
