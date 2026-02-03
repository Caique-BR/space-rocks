class_name Dreadnought
extends AnimatableBody2D

@export var health = 3
@export var checkpoints : Array[Vector2] ## 0 = spawn, 1 enters screen, 2 = top left, 3 bot left, 4 top right, 5 bot right
var speed = 100

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var next_position : Vector2 = checkpoints[3]
	look_at(next_position)
	position += transform.x * (speed * delta)
