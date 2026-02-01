class_name ShieldComponent
extends Node

signal shield_broken()
signal shield_changed(shield: float)

@export var health_component: HealthComponent
@export var shield : float = 0.0: set = set_shield, get = get_shield # Shield's current value
@export var max_shield : float = 100.0 # Shield's max value
@export var shield_regen : float = 5.0 # Shield's recharge delay

var can_regen : bool = false

func _process(delta: float) -> void:
	if can_regen and shield < 100.0:
		shield += shield_regen * delta

func set_shield(value: float) -> void:
	shield = clampf(value, 0, max_shield)
	
	if shield <= 0:
		health_component.health -= 1
		shield_broken.emit()
		get_tree().create_timer(1).timeout.connect(func(): can_regen = true)
	shield_changed.emit(shield)

func get_shield() -> float:
	return shield
