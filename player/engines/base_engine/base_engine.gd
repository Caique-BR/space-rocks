class_name BaseEngine
extends ShipEngine

func _ready() -> void:
	power = 2000
	armor = 10

func thrust():
	thrust_sprite.play("thrust")

func idle():
	thrust_sprite.play("default")
