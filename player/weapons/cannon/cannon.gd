class_name Cannon
extends Weapon

@onready var sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
var shooting : bool = false
var left_bullet : CannonBullet;
var right_bullet : CannonBullet

func shoot() -> void:
	left_bullet = projectile_scene.instantiate()
	right_bullet = projectile_scene.instantiate()
	
	sprite.play("shoot")
	shooting = true

## BUILT-IN

func _ready() -> void:
	fire_rate = 0.1

## SIGNAL HANDLERS

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "shoot":
		if sprite.frame == 2:
			left_bullet.start($Muzzles/MuzzleLeft.global_transform)
			get_tree().root.add_child(left_bullet)
			left_bullet.hitbox_component.set_collision_layer_value(1, false) ## remove layer from players' layer
			left_bullet.hitbox_component.set_collision_mask_value(1, false) ## remove mask from players' mask
			
			left_bullet.hitbox_component.set_collision_layer_value(2, true) ## add layer from enemy layer
			left_bullet.hitbox_component.set_collision_mask_value(2, true) ## add mask from enemy mask

			left_bullet.hitbox_component.set_collision_layer_value(3, true) ## add layer from obstacle layer
			left_bullet.hitbox_component.set_collision_mask_value(3, true) ## add mask from obstacle mask

		if sprite.frame == 3:
			right_bullet.start($Muzzles/MuzzleRight.global_transform)
			get_tree().root.add_child(right_bullet)
			
			right_bullet.hitbox_component.set_collision_layer_value(1, false) ## remove layer from players' layer
			right_bullet.hitbox_component.set_collision_mask_value(1, false) ## remove mask from players' mask
			
			right_bullet.hitbox_component.set_collision_layer_value(2, true) ## add layer from enemy layer
			right_bullet.hitbox_component.set_collision_mask_value(2, true) ## add mask from enemy mask

			right_bullet.hitbox_component.set_collision_layer_value(3, true) ## add layer from obstacle layer
			right_bullet.hitbox_component.set_collision_mask_value(3, true) ## add mask from obstacle mask

func _on_animated_sprite_2d_animation_finished() -> void:
	if shooting: 
		shooting = false
		sprite.play("default")
