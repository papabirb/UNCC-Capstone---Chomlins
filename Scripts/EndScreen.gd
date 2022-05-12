extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# NODE VAR LABEL
onready var message = $"WinLose Label"
var win_message = "You convinced the town that pets are good! :)"
var lose_message = "The town still thinks pets are bad and kicked you out! :("

# Called when the node enters the scene tree for the first time.
func _ready():
	init()

# INIT - get win/lose flag, set message accordingly
func init():
	if GameLogic.win:
		message.text = win_message
	else:
		message.text = lose_message

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# BUTTON - run singleton clear function, go to main menu

func _on_Button_button_up():
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.clear_values()
	GameLogic.switch_scenes(GameLogic.menu)
