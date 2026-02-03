class_name Dreadnought
extends AnimatableBody2D

@export var health = 3
@export var checkpoints : Array[Vector2] ## 0 = spawn, 1 enters screen, 2 = top left, 3 bot left, 4 top right, 5 bot right

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = PI / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#follow.progress += speed * delta
	#position = follow.global_position
	var next_position : Vector2 = checkpoints[3]
	look_at(next_position)
	move_toward(position, next_position, delta)
