extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# BOSS HEALTH
export var bossHealthMax = 100
onready var bossHealth = $"CenterHealth/Boss Health"
# PET HEALTH
export var petHealthMax = 100
onready var petHealth = $"CenterHealth2/Pet Health"
# DAMAGE NUM
export var regDamage = 25
# DAMAGE MODIFIER FOR PET NEEDS
export var damMod = 1.5
# DAMAGE FOR BAD CHOICE
export var damBad = 5
# TURN COUNTER
export var turnsMax = 6
onready var turns = $"DivTextArea/Turn Num"
var thisTurn = -1
# EVENT TEXT
onready var event = $"DivTextArea/Event Text"
# PET NEED ENUM
enum needsDef {FEED = 0, PET = 1, PLAY = 2, CLEAN = 3}
# PET NEED ARRAY
var petNeeds = []
# PET CHOICE GOOD STRING
var choiceBad = " They hated it! The enemy thought your pet's reaction was repulsive!"
# PET CHOICE BAD STRING
var choiceGood = " They loved it! The enemy thought your pet's reaction was super cute!"
# ENEMY EVENT ARRAY
var enemyEvent = []
# ENEMY THEME ARRAY
var enemyTheme = []
# PET CHOICE ARRAY
var petChoice = null
var petEvent = []
# RANDOM NUM GEN
var rng
# VICTORY FOR THIS BATTLE
var wonBattle = false
# TWEENING VARS
export var shakeRange = 5
export var shakeDuration = .1
export var shakeLoopMax = 10
signal finished_shaking
# SOUND VARS
export var hurtMin = 0.75
export var hurtMax = 1.25
export var clickMin = 0.75
export var clickMax = 1.25

# Called when the node enters the scene tree for the first time.
func _ready():
	init_battle()

# INIT BATTLE - randomize color of boss; set all pet needs to false; 
# set boss and pet health to full; set event arrays
func init_battle():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	rand_boss_color()
	init_health()
	init_arrays()
	disable_fight_buttons(true)
	$StartFight.visible = true
	track_turns()

# RANDOM COLOR
func rand_boss_color():
	var col = Color(rng.randf(), rng.randf(), rng.randf())
	$CenterBoss/Boss/Default.self_modulate = col
	GameLogic.townPets[GameLogic.currentTowny] = col

# TURN TRACK
func track_turns():
	thisTurn += 1
	turns.text = String(thisTurn) + "/" + String(turnsMax)

# INIT HEALTH
func init_health():
	bossHealth.value = bossHealthMax
	petHealth.value = petHealthMax

# INIT NEEDS
func init_pet_needs():
	for need in needsDef:
		petNeeds.append(false)

# INIT EVENTS
func init_events():
	init_pet_events()
	init_enemy_events()

# INIT PET EVENTS
func init_pet_events():
	var feedPet = "You give your pet fresh food!"
	var petPet = "You pet your pet!"
	var playPet = "You play with your pet!"
	var cleanPet = "You give your pet a bath!"
	petEvent = [feedPet, petPet, playPet, cleanPet]

# INIT ENEMY EVENTS
func init_enemy_events():
	enemyTheme = [" threw mud on ", " threw trash on ", " stole "]
	var petSupplies = ["your pet's food!", "your pet's brushes!", "your pet's toys!", "your pet!", "your pet's shampoo!"]
	for e in enemyTheme.size():
		enemyEvent.append([])
		for p in petSupplies.size():
			var thief = (e == GameLogic.townies.THIEF && p == needsDef.CLEAN)
			var notThief = (e != GameLogic.townies.THIEF && p == (petSupplies.size() - 1))
			if(thief || notThief):
				continue
			var event = "The enemy" + enemyTheme[e] + petSupplies[p]
			enemyEvent[e].append(event)

# INIT ARRAYS
func init_arrays():
	init_pet_needs()
	init_events()

# TURN LOGIC (int choice) - turn counter plus one, process attack on boss, 
# yield to a tween anim, check if won, else run boss attack, yield to a tween anim
func turn_logic(choice):
	disable_fight_buttons(true)
	track_turns()
	pet_attack(choice)
	yield(self, "finished_shaking")
	check_win()
	if(!wonBattle):
		boss_attack()
		yield(self, "finished_shaking")
		check_lose()
		disable_fight_buttons(false)

# ANIMATION AND SOUND
func anim_sound(sprite, sound):
	if(sound):
		#SFX randomly generated on sfxr.me
		GameLogic.sound($HurtSFX, hurtMin, hurtMax)
	var spriteStart = sprite.position
	var x = spriteStart.x
	var y = spriteStart.y
	for shake in shakeLoopMax:
		$Tween.interpolate_property(sprite, "position", 
		Vector2(rng.randf_range(x-shakeRange, x+shakeRange), y), Vector2(rng.randf_range(x-shakeRange, x+shakeRange), y), 
		shakeDuration, Tween.TRANS_ELASTIC)
		$Tween.start()
		yield($Tween, "tween_completed")
	sprite.position = spriteStart
	emit_signal("finished_shaking")


# CHECK WIN - if win, call win logic
func check_win():
	if bossHealth.value <= 0:
		wonBattle = true
		on_win()

# CHECK LOSE - if lose, call lose logic
func check_lose():
	if petHealth.value <= 0 || thisTurn == turnsMax:
		on_lose()

# WIN BATTLE LOGIC - set singleton victory flag, ++ singleton progress by 33, 
# set end fight button to enabled and visisble
func on_win():
	GameLogic.townVictories[GameLogic.currentTowny] = true
	GameLogic.gameProgress += 33
	event.visible = false
	$EndFight.disabled = false
	$EndFight.visible = true
	

# LOSE BATTLE LOGIC - go to end scene
func on_lose():
	GameLogic.lose = true
	GameLogic.switch_scenes(GameLogic.end)

# BOSS ATTACK LOGIC - randnum, process damage to pet
func boss_attack():
	var attack = rng.randi_range(needsDef.FEED, needsDef.CLEAN)
	damage_to_pet(attack)

# PET DAMAGE LOGIC (int num) - set need[num] to true, take damage (more if it was already true), set event text
func damage_to_pet(num):
	var thisEvent = enemyEvent[GameLogic.currentTowny][num]
	if petNeeds[num] == false:
		petNeeds[num] = true
		petHealth.value -= regDamage
		event.text = thisEvent
	else:
		petHealth.value -= (regDamage * damMod)
		event.text = thisEvent + " They haven't recovered from last time!"
	anim_sound($CenterPet/Pet/Default, true)

# PET ATTACK LOGIC (int num) - if need[num] false, take small damage;
# else set to false, heal, calc damage to boss, set event text
func pet_attack(num):
	if petNeeds[num] == false:
		petHealth.value -= damBad
		event.text = petEvent[num] + choiceBad
		anim_sound($DummySprite, false)
	else:
		petHealth.value += regDamage
		petNeeds[num] = false
		event.text = petEvent[num] + choiceGood
		damage_to_boss()

# CALC DAMAGE TO BOSS - use current pet health as percentage modifier of attack val
func damage_to_boss():
	anim_sound($CenterBoss/Boss/Default, true)
	var dam = regDamage - (1 - (petHealth.value / petHealthMax))
	bossHealth.value -= dam

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# TOGGLE FIGHT BUTTONS
func disable_fight_buttons(state):
	$GridContainer/Feed.disabled = state
	$GridContainer/Pet.disabled = state
	$GridContainer/Play.disabled = state
	$GridContainer/Clean.disabled = state

# BUTTON - CALCULATE BOSS'S FIRST ATTACK, DISABLE STARTFIGHT BUTTON, INVISIBLE IT
func _on_StartFight_button_up():
	$StartFight.disabled = true
	$StartFight.visible = false
	boss_attack()
	disable_fight_buttons(false)

# BUTTON - RETURN TO TOWN MAP
func _on_EndFight_button_up():
	GameLogic.switch_scenes(GameLogic.town)

# BUTTON - FEED PET
func _on_Feed_button_up():
	#SFX randomly generated on sfxr.me
	GameLogic.sound($ClickSFX, clickMin, clickMax)
	yield($ClickSFX, "finished")
	turn_logic(needsDef.FEED)

# BUTTON - PET PET
func _on_Pet_button_up():
	GameLogic.sound($ClickSFX, clickMin, clickMax)
	yield($ClickSFX, "finished")
	turn_logic(needsDef.PET)

# BUTTON - PLAY WITH PET
func _on_Play_button_up():
	GameLogic.sound($ClickSFX, clickMin, clickMax)
	yield($ClickSFX, "finished")
	turn_logic(needsDef.PLAY)

# BUTTON - CLEAN PET
func _on_Clean_button_up():
	GameLogic.sound($ClickSFX, clickMin, clickMax)
	yield($ClickSFX, "finished")
	turn_logic(needsDef.CLEAN)
