class_name Portal
extends Node2D

@onready var portal_sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")

var tween_spawn : Tween

func spawn_portal(pos: Vector2, _look_direction: Vector2 = Vector2.ZERO):
	portal_sprite.scale = Vector2.ZERO
	global_position = pos
	
	if tween_spawn: tween_spawn.kill()
	tween_spawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_spawn.tween_property(portal_sprite, "scale", Vector2(3.0, 3.0), 1)
