class_name ShieldComponent
extends Node

signal shield_broken()
signal shield_changed(shield: float)

@export var health_component: HealthComponent
@export var max_shield : float = 0.0 # Shield's max value
@export var shield : float = 0.0 : set = set_shield, get = get_shield # Shield's current value
@export var shield_regen : float = 0.0 # Shield's recharge delay
@export var shield_regen_timer : float = 0.0 # Shield's recharge delay

@onready var regen_timer : Timer = get_node("RegenTimer")

func _process(delta: float) -> void:
	if not regen_timer.time_left and shield != max_shield:
		shield += shield_regen * delta

func set_shield(value: float) -> void:
	if health_component and health_component.invencible: return
	
	if value < shield:
		if regen_timer:
			regen_timer.start(shield_regen_timer)
	
	shield = clampf(value, 0.0, max_shield)
	
	if shield <= 0:
		health_component.health -= 25
		shield_broken.emit()
		shield = max_shield

	shield_changed.emit(shield)

func get_shield() -> float:
	return shield
