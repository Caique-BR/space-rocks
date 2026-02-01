class_name HurtboxComponent
extends Area2D

signal damage_taken(total: int)

@export var health_component: HealthComponent
@export var shield_component: ShieldComponent

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: HitboxComponent):
	if shield_component: shield_component.shield -= hitbox.damage * 25
	else: health_component.health -= hitbox.damage
	damage_taken.emit(hitbox.damage)
