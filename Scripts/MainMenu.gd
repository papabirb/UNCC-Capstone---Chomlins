extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# BUTTON - go to town map

func _on_Button_button_up():
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.startBGM()
	GameLogic.switch_scenes(GameLogic.town)
