class_name HealthComponent
extends Node

signal health_changed(old_value: int, new_value: int)
signal health_depleted

@export var health : int = 0: set = set_health

func set_health(value: int) -> void:
	var old_health_value = health
	health = value
	
	if health <= 0:
		health_depleted.emit()
	else:
		health_changed.emit(old_health_value, health)
