class_name HitboxComponent
extends Area2D

signal hit(hurtbox)

@export var damage : int = 0

func disable_hitbox():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

func enable_hitbox():
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(area):
	print(area.get_parent())
	if area is HurtboxComponent:
		emit_signal("hit", area)
