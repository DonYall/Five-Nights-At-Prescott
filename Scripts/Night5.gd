extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$OfficeArea.hashir_spawn()
	$OfficeArea.pramit_position = 0
	$OfficeArea/Office/RiyyanAtDoor.visible = true
	$OfficeArea/Office/MohamedAtDoor.visible = true
	$OfficeArea/OfficeLight.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ($OfficeArea/OfficeLight.modulate.a < 100):
		$OfficeArea/OfficeLight.modulate.a += delta * 0.005

func _on_wait_timeout():
	$OfficeArea.close_monitor()
	$Monologue.play()

func _on_monologue_finished():
	$OfficeArea.modulate.a = 100
	
