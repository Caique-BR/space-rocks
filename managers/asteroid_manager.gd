class_name AsteroidManager
extends Node

@export var asteroid_scene : PackedScene
@export var spawn_noise : Noise

var screen_size : Vector2 = Vector2.ZERO : get = _get_screen_size

func spawn_asteroid(amount: int) -> void:
	spawn_noise.get_noise_2d(0, 0)
	for x in range(amount):
		pass;

func _ready() -> void:
	spawn_asteroid(5)
	print(spawn_noise.get_noise_2d(512, 512))
	print(spawn_noise.get_noise_2d(300, 300))

## Handlers

func _get_screen_size() -> Vector2:
	return get_viewport().get_visible_rect().size
