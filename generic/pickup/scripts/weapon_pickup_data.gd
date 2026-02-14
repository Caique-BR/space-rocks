class_name WeaponPickupData
extends PickupData

@export var weapon_scene : PackedScene

func apply(target: Player) -> void:
	target.pickup_weapon(weapon_scene)
