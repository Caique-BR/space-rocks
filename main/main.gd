extends Node

@export var DEBUGGING : bool =  false

# change spawn timer on new level to 5, 10

@export var asteroid_scene : PackedScene
@export var enemy_scene : PackedScene

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false

func _ready(): # determins the asteroid spawn point
	screensize = get_viewport().get_visible_rect().size
	
	new_game()
	
	###### DEBUG
	if DEBUGGING:
		$ExplosionSound.volume_db = -100
		$LevelupSound.volume_db = -100
		$Music.volume_db = -100

func spawn_asteroid(size, pos = null, vel = null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position

	if vel == null: 
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)

	var a : Asteroid = asteroid_scene.instantiate()

	call_deferred("add_child", a)
	a.screensize = screensize
	a.start(pos, vel, size)
	a.exploded.connect(self._on_asteroid_exploded)

func _on_asteroid_exploded(size, radius, pos, vel): #dupes the asteroids that gets shot
	$ExplosionSound.play()
	score += 1
	if size <= 1: $HUD.update_score(score)
	else:
		for offset in [-1, 1]:
			var dir = $Player.position.direction_to(pos).orthogonal() * offset
			
			var newpos = pos + dir * radius
			var newvel = dir * vel.length() * 1.1
			spawn_asteroid(size - 1, newpos, newvel)
			$HUD.update_score(score)

func new_game(): # starts the game when receiving the "start_game" signal
	$Player.show()
	get_tree().call_group("asteroids", "queue_free") # removes asteroids from previous run
	level = 0 
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true
	$Music.play()

func new_level(): # increaces the difficult when changing levels
	level += 1
	$LevelupSound.play()
	
	$HUD.show_message("Wave %s" % level)
	$EnemyTimer.start(randi_range(1, 3)) # enemy spawn on timer end
	
	for i in level: spawn_asteroid(3)

func _process(_delta): # changes the level when all the asteroids are destroyed in the currente level
	if not playing:
		return
	if get_tree().get_nodes_in_group("asteroids").size() == 0:
		new_level()

func game_over():
	playing = false
	$HUD.game_over()
	$Music.stop()

func _input(event): # pause game func
	if event.is_action_pressed("pause"):
		if not playing: return
		get_tree().paused = not get_tree().paused
		var message = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide()

func _on_enemy_timer_timeout(): # enemy spawn
	var e = enemy_scene.instantiate()
	add_child(e)
	e.target = $Player
	$EnemyTimer.start(randf_range(20, 40)) # reset the enemy timer 
