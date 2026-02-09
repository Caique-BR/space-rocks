class_name Blaster
extends Weapon

@onready var sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
var shooting : bool = false
var bullet : BlasterBullet;

func shoot() -> void:
	bullet = projectile_scene.instantiate()
	
	sprite.play("shoot")
	shooting = true

## BUILT-IN

func _ready() -> void:
	fire_rate = 1

## SIGNAL HANDLERS

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "shoot":
		if sprite.frame == 7:
			bullet.start($Muzzle.global_transform)
			get_tree().root.add_child(bullet)
			
			bullet.hitbox_component.set_collision_layer_value(1, false) ## remove layer from players' layer
			bullet.hitbox_component.set_collision_mask_value(1, false) ## remove mask from players' mask
			
			bullet.hitbox_component.set_collision_layer_value(2, true) ## add layer from enemy layer
			bullet.hitbox_component.set_collision_mask_value(2, true) ## add mask from enemy mask

			bullet.hitbox_component.set_collision_layer_value(3, true) ## add layer from obstacle layer
			bullet.hitbox_component.set_collision_mask_value(3, true) ## add mask from obstacle mask

func _on_animated_sprite_2d_animation_finished() -> void:
	if shooting: 
		shooting = false
		sprite.play("default")
