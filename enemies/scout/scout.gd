class_name Scout
extends Node2D

signal routine_ended

@onready var scout_bullet_scene : PackedScene = load("res://enemies/scout/scout_bullet/scout_bullet.tscn")
@onready var portal_scene : PackedScene = load("res://generic/portal/portal.tscn")

@onready var ship_sprite : AnimatedSprite2D = get_node("ShipSprite")
@onready var shield_sprite : AnimatedSprite2D = get_node("ShieldSprite")
@onready var engine_sprite : AnimatedSprite2D = get_node("EngineSprite")
@onready var engine_particles_left : CPUParticles2D = get_node("EngineParticles")
@onready var engine_particles_right : CPUParticles2D = get_node("EngineParticles")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")

@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")
@onready var hurtbox_component : HurtboxComponent = get_node("HurtboxComponent")

var velocity : Vector2 = Vector2.ZERO
var speed : int = 3000
var delta_count : float = 0.0

var on_routine: bool = false
var shooting : bool = false

var tween_move : Tween
var tween_scale : Tween
var tween_damage : Tween
var bullet : ScoutBullet

func shoot():
	if shooting: return
	bullet = scout_bullet_scene.instantiate()
	
	ship_sprite.play("shoot")
	shooting = true

func vanish(): 
	var portal : Portal = portal_scene.instantiate()
	get_tree().root.add_child(portal)
	
	rotation = 0.0
	portal.spawn_portal(global_position + transform.x * 300)
	
	if tween_move: tween_move.kill()
	if tween_scale: tween_scale.kill()
	
	tween_move = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween_move.tween_property(self, "global_position", portal.global_position + transform.x * 100, 1.5)
	
	await get_tree().create_timer(0.825).timeout
	portal.bump_portal()
	hide()
	
	hitbox_component.disable_hitbox()
	hurtbox_component.disable_hurtbox()

##

func start_routine(_transform: Transform2D, _side: int):
	transform = _transform
	velocity = transform.x
	
	if tween_move: tween_move.kill()
	tween_move = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_move.tween_property(self, "position", position + transform.x * 200, 1)
	
	await tween_move.finished
	CameraControls.camera.screen_shake(10, 1)
	on_routine = true

func start_shooting(shooting_point: Transform2D):
	transform = shooting_point
	var final_position = Vector2(position)
	position += transform.x * -1 * 200 
	if tween_move: tween_move.kill()
	tween_move = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_move.tween_property(self, "position", final_position, 1)
	
	await tween_move.finished
	shoot()

## BUILT-IN

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	vanish()

func _process(delta: float) -> void:
	delta_count += delta
	if on_routine : position += velocity * speed * delta

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
	await ship_sprite.animation_finished
	queue_free()

func _on_ship_sprite_frame_changed() -> void:
	if shooting:
		if ship_sprite.frame == 3:
			get_tree().root.add_child(bullet)
			bullet.start([1], $Muzzle.global_transform)

func _on_ship_sprite_animation_finished() -> void:
	if ship_sprite.animation == "shoot":
		shooting = false
		shoot()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if on_routine:
		on_routine = false
		routine_ended.emit()
