class_name Fighter
extends Node2D


@onready var ship_sprite : AnimatedSprite2D = get_node("ShipSprite")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")
@onready var hurtbox_component : HurtboxComponent = get_node("HurtboxComponent")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")

var tween_damage : Tween

## BUILT-IN

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

## SIGNAL HANDLERS

func _on_health_changed(_new_value: int) -> void:
	if animation_player.is_playing(): animation_player.stop()
	animation_player.play("hurt")
	ship_sprite.frame += 1
	ship_sprite.scale = Vector2(2.8, 2.8)
	
	if tween_damage: tween_damage.kill()
	tween_damage = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_damage.tween_property(ship_sprite, "scale", Vector2(3, 3), 0.5)

func _on_health_depleted() -> void:
	hitbox_component.disable_hitbox()	
	hurtbox_component.disable_hurtbox()	
	ship_sprite.play("explode")
