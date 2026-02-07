extends Node2D

@export var fighter_scene : PackedScene

var current_fighters : Array[Fighter] = []
@onready var spawnpoint_x : Marker2D = get_node("SpawnPointX")
@onready var spawnpoint_y : Marker2D = get_node("SpawnPointY")
@onready var path_x : Path2D = get_node("PathX")

func spawn_fighter():
	var fighter = fighter_scene.instantiate()

func spawn_fighter_duo():
	var f1 : Fighter = fighter_scene.instantiate()
	var f2 : Fighter = fighter_scene.instantiate()
	
	f1.routine_ended.connect(_on_routine_ended)
	f2.routine_ended.connect(_on_routine_ended)
	
	current_fighters.append(f1)
	current_fighters.append(f2)
	
	get_tree().root.add_child(f1)
	get_tree().root.add_child(f2)
	
	#f1.start_x_routine(1)
	#f2.start_x_routine(2)

func _on_routine_ended():
	pass;
