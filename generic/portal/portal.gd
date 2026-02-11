class_name Portal
extends Node2D

@export var portal_sprite : AnimatedSprite2D
@export var particles : GPUParticles2D

var tween_spawn : Tween
var tween_bump : Tween

func spawn_portal(pos: Vector2, _look_direction: Vector2 = Vector2.ZERO):
	portal_sprite.scale = Vector2.ZERO
	global_position = pos
	
	if tween_spawn: tween_spawn.kill()
	tween_spawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_spawn.tween_property(portal_sprite, "scale", Vector2(3.0, 3.0), 1)

func bump_portal():
	if tween_spawn: tween_spawn.kill()
	portal_sprite.scale = Vector2(4.0, 4.0)
	if tween_bump: tween_bump.kill()
	tween_bump = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_bump.tween_property(portal_sprite, "scale", Vector2(3.0, 3.0), 1)

func destroy_portal():
	bump_portal()
	await get_tree().create_timer(0.2).timeout
	particles.emitting = false
	tween_bump.kill()
	if tween_spawn: tween_spawn.kill()
	tween_spawn = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween_spawn.tween_property(portal_sprite, "scale", Vector2.ZERO, 0.4)
	await tween_spawn.finished
	queue_free()
