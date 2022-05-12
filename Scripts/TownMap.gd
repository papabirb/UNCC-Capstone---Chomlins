extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# NODE VAR OF THE BUTTONS
onready var enemies = [$Townies/Enemy, $Townies/Enemy2, $Townies/Enemy3]
# NODE VAR OF THE PETS
onready var pets = [$Townies/Enemy/EnemyPet, $Townies/Enemy2/EnemyPet2, $Townies/Enemy3/EnemyPet3]
# NODE FOR PROGRESS
onready var progBar = $YourHome/TextureProgress
# SPECIAL NODE VAR FOR THE END GAME BUTTON
onready var endButt = $EndButton
# NODE/STRING VARS FOR TOWN NAME
onready var town_name = $TownLabel
var town_name_bad = "PETS R BAD VILLE"
var town_name_good = "PETS R GOOD VILLE"


# Called when the node enters the scene tree for the first time.
func _ready():
	init_town()

# INIT - get clear flags from singleton, set corresponding buttons disabled & make pets visible,
# set status of the radial progress bar from singleton progress, enable game over button if won, change town name
func init_town():
	set_buttons_pets()
	set_town_progress()
	set_game_won()
	change_town_name()
	check_win()

# SET BUTTONS AND PETS
func set_buttons_pets():
	for i in len(GameLogic.townVictories):
		enemies[i].disabled = GameLogic.townVictories[i]
		pets[i].visible = GameLogic.townVictories[i]
		# ternary statement to set pet color to the color the boss was in battle, or default if boss hasn't been fought yet
		pets[i].self_modulate = GameLogic.townPets[i] if GameLogic.townPets[i] != null else pets[i].self_modulate

# SET GAME WIN STATE
func set_game_won():
	var state = (progBar.value == progBar.max_value)
	GameLogic.win = state

# CHANGE TOWN NAME
func change_town_name():
	if GameLogic.win:
		town_name.text = town_name_good
	else:
		town_name.text = town_name_bad

# SET TOWN PROGRESS
func set_town_progress():
	progBar.value = GameLogic.gameProgress

# CHECK WIN
func check_win():
	endButt.visible = GameLogic.win
	endButt.disabled = !GameLogic.win

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# ON CLICK FOR EACH BUTTON - set singleton id, call go to battle scene OR go to end scene

func _on_Enemy_button_up():
	GameLogic.currentTowny = GameLogic.townies.MUD
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.switch_scenes(GameLogic.battle)


func _on_Enemy2_button_up():
	GameLogic.currentTowny = GameLogic.townies.TRASH
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.switch_scenes(GameLogic.battle)


func _on_Enemy3_button_up():
	GameLogic.currentTowny = GameLogic.townies.THIEF
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.switch_scenes(GameLogic.battle)


func _on_EndButton_button_up():
	GameLogic.sound($AudioStreamPlayer, 1, 1)
	yield($AudioStreamPlayer, "finished")
	GameLogic.switch_scenes(GameLogic.end)
