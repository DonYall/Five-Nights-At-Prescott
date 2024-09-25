extends Control

@export var scroll_duration = 0.25
var target_scroll = 0
var can_press_monitor = false
var monitor_active = false
var background_width
var background_position_x
var viewport_width
var scroll_tween
var monitor_tween
var pramit_position = 4
var zaid_position = 3
var don_active = false
var hashir_spawn_chance = 0
var noise_level = 0
var foodInput = ""

signal died_to_hashir
signal died_to_zaid

func init(hashir_chance):
	hashir_spawn_chance = hashir_chance

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_width = get_viewport().get_visible_rect().size.x
	background_width = $Office.size.x
	background_position_x = $Office.position.x
	$Office.set_pivot_offset($Office.size / 2)
	$OfficeLight.set_pivot_offset($OfficeLight.size / 2)
	$OfficeLight.position.x = background_position_x - (background_width - viewport_width) / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if monitor_active:
		if Input.is_action_just_pressed("close_monitor"):
			close_monitor()
		return
	elif Input.is_action_just_pressed("f"):
		foodInput += "f"
	elif Input.is_action_just_pressed("o"):
		foodInput += "o"
	elif Input.is_action_just_pressed("d"):
		foodInput += "d"
	elif Input.is_action_just_pressed("?"):
		foodInput += "?"

	if hashir_is_active():
		if foodInput == "food?":
			hashir_leave()
		elif not "food?".begins_with(foodInput):
			emit_signal("died_to_hashir")

	var relative_mouse_x = get_viewport().get_mouse_position().x / viewport_width

	if relative_mouse_x <= 0.15:
		target_scroll = 0
	elif relative_mouse_x >= 0.85:
		target_scroll = background_width - viewport_width
		if pramit_position <= 0 and not scroll_tween and $Office.position.x != background_position_x - target_scroll:
			scroll_tween = get_tree().create_tween()
			scroll_tween.set_parallel(true)
			scroll_tween.tween_property($Office, "position:x", background_position_x - target_scroll, scroll_duration)
			scroll_tween.tween_property($OfficeLight, "position:x", background_position_x - target_scroll, scroll_duration)
			scroll_tween.tween_property($PramitAtDoor, "position:x", viewport_width, scroll_duration)
			scroll_tween.connect("finished", kill_scroll_tween)
			return
		elif $Office.position.x != background_position_x - target_scroll and zaid_position <= 0:
			emit_signal("died_to_zaid")
	else:
		target_scroll = (background_width - viewport_width) / 2

	if not scroll_tween and $Office.position.x != background_position_x - target_scroll:
		scroll_tween = get_tree().create_tween()
		scroll_tween.set_parallel(true)
		scroll_tween.tween_property($Office, "position:x", background_position_x - target_scroll, scroll_duration)
		scroll_tween.tween_property($OfficeLight, "position:x", background_position_x - target_scroll, scroll_duration)
		scroll_tween.tween_property($PramitAtDoor, "position:x", viewport_width + $PramitAtDoor.get_rect().size.x, scroll_duration)
		scroll_tween.connect("finished", kill_scroll_tween)

func kill_scroll_tween():
	if $Office.position.x == background_position_x - (background_width - viewport_width) / 2:
		can_press_monitor = true
	else:
		can_press_monitor = false
	scroll_tween.kill()
	scroll_tween = null

func monitor_opened():
	monitor_tween.kill()
	monitor_tween = null

func monitor_closed():
	monitor_tween.kill()
	monitor_tween = null
	monitor_active = false

func open_monitor():
	if not can_press_monitor:
		return
	if hashir_is_active():
		emit_signal("died_to_hashir")
	if not monitor_active and not monitor_tween:
		monitor_active = true
		$Monitor.visible = true
		monitor_tween = get_tree().create_tween()
		monitor_tween.tween_property($Office, "scale", Vector2(5.2, 5.2), 0.25)
		monitor_tween.tween_property($Monitor, "modulate:a", 1, 0.1)
		monitor_tween.connect("finished", monitor_opened)

func close_monitor():
	if not monitor_active:
		return
	if not monitor_tween:
		if randf() < hashir_spawn_chance:
			hashir_spawn()
		$Monitor.modulate.a = 0
		$Monitor.visible = false
		monitor_tween = get_tree().create_tween()
		monitor_tween.tween_property($Office, "scale", Vector2(1, 1), 0.25)
		monitor_tween.connect("finished", monitor_closed)

func _on_monitor_pressed():
	open_monitor()

func is_looking_at_pramit():
	return target_scroll == background_width - viewport_width

func pramit_timeout():
	if zaid_position <= 0:
		return
	pramit_position -= 1
	if pramit_position == 0:
		$Knock.play()
	if pramit_position < 0:
		pramit_position = 0
	for cam in $Monitor/Cameras/Hallway.get_children():
		cam.visible = false
	$Monitor/Cameras/Hallway.get_node(str(pramit_position)).visible = true

func hashir_spawn():
	$PowerDown.play()
	$Monitor/Cameras/Mohamed/MohamedWake.set_stream_paused(true)
	$Office.set_texture($OfficeDark.get_texture())
	$Office/HashirAtDoor.visible = true
	$HashirKillTimer.start()

func hashir_leave():
	$Office.set_texture($OfficeNormal.get_texture())
	$Office/HashirAtDoor.visible = false
	$HashirKillTimer.stop()
	$Monitor/Cameras/Mohamed/MohamedWake.set_stream_paused(false)
	foodInput = ""

func hashir_is_active():
	return $Office/HashirAtDoor.visible

func _on_hashir_kill_timer_timeout():
	emit_signal("died_to_hashir")
