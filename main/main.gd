extends Node

@export var DEBUGGING : bool =  false
@export var asteroid_scene : PackedScene
@export var dreadnought_scene : PackedScene
@export var portal_scene : PackedScene

# change spawn timer on new level to 5, 10

@onready var hud : HUD = get_node("HUD")
@onready var fighter_spawner : FighterSpawner = get_node("FighterSpawner")
@onready var camera : Camera = get_node("Camera2D")
@onready var boss_timer : Timer = get_node("DreadnoughtTimer")

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false

func spawn_boss():
	if level == 1: boss_timer.start()

func spawn_asteroid():
	$RockPath/RockSpawn.progress = randi()

	var pos = $RockPath/RockSpawn.position
	var vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)

	var a : Asteroid = asteroid_scene.instantiate()

	a.start(pos, vel)
	a.exploded.connect(self._on_asteroid_exploded)
	call_deferred("add_child", a)

func new_game(): # starts the game when receiving the "start_game" signal
	$Player.show()
	get_tree().call_group("asteroids", "queue_free") # removes asteroids from previous run
	level = 0 
	score = 0
	$Player.reset()
	playing = true
	$Music.play()

func new_level(): # increaces the difficult when changing levels
	level += 1
	$LevelupSound.play()
	
	for i in level: spawn_asteroid()

func game_over():
	playing = false
	$Music.stop()

## BUILT-IN

func _ready():
	screensize = get_viewport().get_visible_rect().size
	CameraControls.camera = camera
	
	new_game()
	
	###### DEBUG
	if DEBUGGING:
		$ExplosionSound.volume_db = -100
		$LevelupSound.volume_db = -100
		$Music.volume_db = -100

func _process(_delta): # changes the level when all the asteroids are destroyed in the currente level
	if not playing:
		return
	if get_tree().get_nodes_in_group("asteroids").size() == 0:
		new_level()

func _input(event): # pause game func
	if event.is_action_pressed("pause"):
		if not playing: return
		get_tree().paused = not get_tree().paused
	if event.is_action_pressed("spawn_asteroid"):
		$RockPath/RockSpawn.progress = randi()

		var pos = get_viewport().get_mouse_position()
		var vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)

		var a : Asteroid = asteroid_scene.instantiate()

		a.start(pos, vel)
		a.exploded.connect(self._on_asteroid_exploded)
		call_deferred("add_child", a)

## SIGNAL HANDLERS

func _on_asteroid_exploded(): #dupes the asteroids that gets shot
	#camera.screen_shake(15, 0.5)
	$ExplosionSound.play()
	score += 1

func _on_dreadnought_timertest_timeout() -> void:
	var dreadnought : Dreadnought = dreadnought_scene.instantiate()
	dreadnought.position = Vector2(950, -200)
	#add_child(dreadnought)
