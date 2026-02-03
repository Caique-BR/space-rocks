class_name HitboxComponent
extends Area2D

signal hit(hurtbox)

@export var damage : int = 0

func disable_hurtbox():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

func enable_hurtbox():
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(area):
	if area is HurtboxComponent:
		emit_signal("hit", area)
