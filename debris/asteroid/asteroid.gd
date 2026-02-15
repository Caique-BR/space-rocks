class_name Asteroid
extends Debris

signal exploded

@export var asteroid_debris_scene : PackedScene
@export var animated_sprite2d : AnimatedSprite2D
@export var animation_player : AnimationPlayer

var tween : Tween

func explode() -> void:
	stop_motion()
	hitbox_component.disable_hitbox()
	hurtbox_component.disable_hurtbox()
	
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	for offset in [-1, 1]:
		var asteroid_debris : AsteroidDebris = asteroid_debris_scene.instantiate()
		asteroid_debris.set_side(offset)
		
		var debris_transform = Transform2D(transform)
		debris_transform.origin = debris_transform.origin + (transform.x * 10 * offset)
		
		asteroid_debris.start(
			debris_transform, ## `parameter for transform`
			transform.x * 200 * offset ## `parameter for linear_velocity`
		)
		
		get_tree().root.add_child(asteroid_debris)
	
	CameraControls.camera.screen_shake(10, 0.1)
	exploded.emit()
	drop_component.drop(global_position)
	queue_free()

## Handlers

func _on_health_changed(health: int) -> void:
	if health == health_component.max_health: return
	
	animation_player.play("hurt")
	animated_sprite2d.frame += 1
	animated_sprite2d.scale = Vector2(3, 3)
	
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite2d, "scale", Vector2(3.5, 3.5), 0.5)

func _on_health_depleted() -> void:
	animation_player.play("hurt")
	
	hitbox_component.disable_hitbox()
	hurtbox_component.disable_hurtbox()
	
	CameraControls.camera.screen_shake(10, 0.25)
	explode()

func _on_mouse_entered() -> void:
	Utilily.print_on_screen("mouse_entered")
