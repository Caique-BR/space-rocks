class_name AsteroidDebris
extends Debris

@export var animated_sprite2d : AnimatedSprite2D
@export var animation_player : AnimationPlayer

@export var left_side_collision : CollisionPolygon2D
@export var right_side_collision : CollisionPolygon2D

var side : int
var tween : Tween

func set_side(s: int) -> void: 
	side = s

## Animations

func explode() -> void:
	stop_motion()
	hurtbox_component.disable_hurtbox()
	hitbox_component.disable_hitbox()
	
	animated_sprite2d.scale = Vector2(2.0, 2.0)
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	queue_free()

func hurt() -> void:
	if tween: tween.kill()
	animation_player.play("hurt")
	animated_sprite2d.scale = Vector2(3.0, 3.0)
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite2d, "scale", Vector2(3.5, 3.5), 1)

## Built-in

func _ready() -> void:
	var collision_shape : CollisionPolygon2D
	
	if side == -1:
		collision_shape = left_side_collision
		animated_sprite2d.animation = "debris_left"
	elif side == 1:
		collision_shape = right_side_collision
		animated_sprite2d.animation = "debris_right"
	
	collision_shape_2d = collision_shape
	collision_shape_2d.show()
	collision_shape.disabled = false
	hurtbox_component.add_child(collision_shape.duplicate())
	hitbox_component.add_child(collision_shape.duplicate())

## Handlers

func _on_health_changed(new_value: int) -> void:
	if new_value != health_component.max_health:
		hurt()

func _on_health_depleted() -> void:
	explode()
