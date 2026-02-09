class_name FighterSpawner
extends Node2D

@export var fighter_scene : PackedScene

var current_fighters : Array[Fighter] = []
@onready var spawnpoint_x : Marker2D = get_node("SpawnPointX")
@onready var spawnpoint_y : Marker2D = get_node("SpawnPointY")
@onready var shooting_positions : Array[Marker2D] = []

var shooting_stage : bool = false

func _ready() -> void:
	for child in get_children():
		if child.name.begins_with("Shooting"):
			shooting_positions.append(child)

func spawn_fighter():
	var _fighter = fighter_scene.instantiate()

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
		var new_transform = Transform2D(spawnpoint_x.global_transform)
		new_transform.origin.y += 150 * side
		fighter.start_routine(new_transform, side)
		await get_tree().create_timer(0.25).timeout
		side *= -1

func start_y_routine():
	var side = 1
	
	for fighter in current_fighters:
		get_tree().root.add_child(fighter)
		var new_transform = Transform2D(spawnpoint_y.global_transform)
		new_transform.origin.x += 150 * side
		fighter.start_routine(new_transform, side)
		await get_tree().create_timer(0.25).timeout
		side *= -1
	
	shooting_stage = true

func start_shooting_routine():
	for fighter in current_fighters:
		var spot : Marker2D = shooting_positions.pick_random()
		while spot.get_meta("taken"): spot = shooting_positions.pick_random()
		spot.set_meta("taken", true)
		fighter.start_shooting(spot.transform)

func _on_routine_ended():
	if current_fighters.all(func(fighter: Fighter): return not fighter.on_routine):
		await get_tree().create_timer(1).timeout
		if shooting_stage: start_shooting_routine()
		else: start_y_routine()
