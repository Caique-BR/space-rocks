class_name Cannon
extends Weapon

func shoot() -> void:
	var b : CannonBullet = projectile_scene.instantiate()
	b.start($Muzzles/MuzzleLeft.global_transform)
	get_tree().root.add_child(b)
	print("a")

## BUILT-IN

func _ready() -> void:
	pass;
