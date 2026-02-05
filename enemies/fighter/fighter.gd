class_name Fighter
extends Node2D

@onready var fighter_bullet_scene : PackedScene = load("res://enemies/fighter/fighter_bullet/fighter_bullet.tscn")
@onready var ship_sprite : AnimatedSprite2D = get_node("ShipSprite")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")
@onready var hurtbox_component : HurtboxComponent = get_node("HurtboxComponent")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")

var tween_damage : Tween
var shooting : bool = false
var bleft : FighterBullet
var bright : FighterBullet

func shoot():
	if shooting: return
	bleft = fighter_bullet_scene.instantiate()
	bright = fighter_bullet_scene.instantiate()
	
	ship_sprite.play("shoot")
	shooting = true
	
## BUILT-IN

func _ready() -> void:
	pass # Replace with function body.
	shoot()

func _process(_delta: float) -> void:
	pass

## SIGNAL HANDLERS

func _on_health_changed(_new_value: int) -> void:
	if animation_player.is_playing(): animation_player.stop()
	animation_player.play("hurt")
	ship_sprite.scale = Vector2(2.8, 2.8)
	
	if tween_damage: tween_damage.kill()
	tween_damage = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_damage.tween_property(ship_sprite, "scale", Vector2(3, 3), 0.5)

func _on_health_depleted() -> void:
	hitbox_component.disable_hitbox()	
	hurtbox_component.disable_hurtbox()	
	ship_sprite.play("explode")

func _on_ship_sprite_frame_changed() -> void:
	if shooting:
		if ship_sprite.frame == 1:
			get_tree().root.add_child(bleft)
			bleft.start([1], $MuzzleLeft.global_transform)
		elif ship_sprite.frame == 5:
			get_tree().root.add_child(bright)
			bright.start([1], $MuzzleRight.global_transform)

func _on_ship_sprite_animation_finished() -> void:
	if ship_sprite.animation == "shoot":
		shooting = false
		shoot()
