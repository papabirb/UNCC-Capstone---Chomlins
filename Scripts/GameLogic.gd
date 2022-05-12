extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# SCENE VARS
var menu = "res://Scenes/MainMenu.tscn"
var end = "res://Scenes/EndScreen.tscn"
var battle = "res://Scenes/BattleScene.tscn"
var town = "res://Scenes/TownMap.tscn"
# VICTORIES ARRAY
var townVictories = []
# PET COLORS ARRAY
var townPets = []
# WIN/LOSE FLAG
var win
var lose
# ENUM {mud, trash, thief}
enum townies {MUD = 0, TRASH = 1, THIEF = 2}
# CURRENT FIGHT ID
var currentTowny
# TOWN PROGRESS
var gameProgress
# RNG
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_values()

# GO TO SCENE
func switch_scenes(scn):
	get_tree().change_scene(scn)

# SOUND
func sound(node, minPitch, maxPitch):
	node.pitch_scale = rng.randf_range(minPitch, maxPitch)
	node.play()

# CLEAR VALUES
func clear_values():
	$AudioStreamPlayer.stop()
	townVictories.clear()
	townPets.clear()
	rng = RandomNumberGenerator.new()
	rng.randomize()
	for towny in townies:
		townVictories.append(false)
		townPets.append(null)
	win = false
	lose = false
	currentTowny = null
	gameProgress = 0
	$AudioStreamPlayer.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
