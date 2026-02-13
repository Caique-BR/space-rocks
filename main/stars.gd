
class_name Stars
extends Node2D
@export var player : Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(player.linear_velocity)
	global_position = player.global_position - Vector2(960, 540)
	$GPUParticles2D.process_material.gravity = Vector3(0, 0, 0)
