class_name CannonGun
extends Gun

func shoot() -> void:
	var projectile : CannonProjectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.start([2, 3], muzzle.global_transform)
	if gun_sprite.is_playing(): gun_sprite.stop()
	gun_sprite.play("shoot")
	
