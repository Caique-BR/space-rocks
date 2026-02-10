class_name HealthComponent
extends Node

signal max_health_changed(new_value: int)
signal health_changed(new_value: int)
signal health_depleted

@export var max_health : float = 0.0 : set = set_max_health;
@export var invencible : bool = false
var health : float = 0.0 : set = set_health

func _ready() -> void:
	health = max_health

func set_max_health(value: float) -> void:
	if invencible: return
	
	var clamped_value : float = 1.0 if value <= 0.0 else value
	
	if not clamped_value == max_health:
		max_health = value
		max_health_changed.emit(max_health)
		
		if health > max_health:
			health = max_health

func set_health(value: float) -> void:
	health = value
	
	if not health == max_health:
		if health <= 0: health_depleted.emit()
		else: health_changed.emit(health)
