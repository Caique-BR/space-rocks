class_name DropComponent
extends Node

@export var total_experience_drop : int

@onready var experience_cluster : PackedScene = load("res://generic/experience_cluster/experience_cluster.tscn")

func drop(position: Vector2) -> void:
	var exp_cluster : ExperienceCluster = experience_cluster.instantiate()
	exp_cluster.start(100, total_experience_drop)
	exp_cluster.global_position = position
	get_tree().root.add_child(exp_cluster)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
