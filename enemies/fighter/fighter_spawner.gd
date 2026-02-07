class_name FighterSpawner
extends Node2D

@export var fighter_scene : PackedScene

var current_fighters : Array[Fighter] = []
@onready var spawnpoint_x : Marker2D = get_node("SpawnPointX")
@onready var spawnpoint_y : Marker2D = get_node("SpawnPointY")

func spawn_fighter():
	var fighter = fighter_scene.instantiate()

func spawn_fighter_duo():
	var f1 : Fighter = fighter_scene.instantiate()
	var f2 : Fighter = fighter_scene.instantiate()
	
	f1.routine_ended.connect(_on_routine_ended)
	f2.routine_ended.connect(_on_routine_ended)
	
	current_fighters.append(f1)
	current_fighters.append(f2)
	start_x_routine()

func start_x_routine():
	var side = 1
	
	for fighter in current_fighters:
		get_tree().root.add_child(fighter)
		fighter.start_routine(spawnpoint_x.global_transform, side)
		await get_tree().create_timer(0.25).timeout
		side *= -1

func start_y_routine():
	var side = 1
	
	for fighter in current_fighters:
		get_tree().root.add_child(fighter)
		fighter.start_routine(spawnpoint_y.global_transform, side)
		await get_tree().create_timer(0.25).timeout
		side *= -1

func _on_routine_ended():
	if current_fighters.all(func(fighter: Fighter): return not fighter.on_routine):
		await get_tree().create_timer(1).timeout
		start_y_routine()
