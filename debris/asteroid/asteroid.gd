class_name Asteroid
extends Debris

signal exploded

@export var collision_shape2d : CollisionShape2D
@export var animated_sprite2d : AnimatedSprite2D
@export var animation_player : AnimationPlayer

var tween : Tween

func explode() -> void:
	collision_shape2d.set_deferred("disabled", true)
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0)
	
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	exploded.emit() # emits the exploded signal for dupping asteroids
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
