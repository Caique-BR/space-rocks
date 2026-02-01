class_name HitboxComponent
extends Area2D

@export var damage : int = 0: set = set_damage, get = get_damage

func set_damage(value: int) -> void:
	damage = value
	
func get_damage() -> int:
	return damage
