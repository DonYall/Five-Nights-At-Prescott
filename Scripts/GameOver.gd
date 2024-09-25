extends Node


func _ready():
	pass

func _process(delta):
	pass

func init(character):
	self.visible = true
	$CloseTimer.start()
	if character == "hashir":
		$HashirJumpscare.visible = true
	elif character == "pramit":
		$PramitJumpscare.visible = true
	elif character == "riyyan":
		$RiyyanJumpscare.visible = true
	elif character == "mohamed":
		$MohamedJumpscare.visible = true
	elif character == "zaid":
		$ZaidJumpscare.visible = true
	else:
		$Label.visible = true
		$Label.text = "game over - " + character

func _on_close_timer_timeout():
	get_tree().quit()
