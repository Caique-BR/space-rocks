class_name BurstEngine
extends ShipEngine

func _ready() -> void:
	power = 3000
	armor = 15

func thrust():
	thrust_sprite.play("thrust")

func idle():
	thrust_sprite.play("default")
