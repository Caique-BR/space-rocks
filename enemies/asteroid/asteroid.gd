class_name Asteroid extends RigidBody2D

signal exploded

@onready var animated_sprite2d : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var collision_shape2d : CollisionShape2D = get_node("CollisionShape2D")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")
@onready var hurtbox_component : HurtboxComponent = get_node("HurtboxComponent")
@onready var health_component : HealthComponent = get_node("HealthComponent")

@onready var asteroid_texture : Texture2D = load("res://assets/asteroid/asteroid.png")

var screensize = Vector2.ZERO
var tween : Tween
var is_debris : bool = false
var debris_side : int = 0

func start(pos, vel): # handles asteroid creation size and speed
	position = pos
	linear_velocity = vel
	angular_velocity = randf_range(-PI, PI)

func start_debris(pos, vel, side): # handles asteroid creation size and speed
	is_debris = true
	position = pos
	linear_velocity = vel
	angular_velocity = randf_range(-PI, PI)
	debris_side = side

func explode(): 
	collision_shape2d.set_deferred("disabled", true)
	linear_velocity = Vector2.ZERO
	
	angular_velocity = 0 
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	exploded.emit() # emits the exploded signal for dupping asteroids
	
	if is_debris: queue_free()
	else:
		for s in [-1, 1]:
			create_debris(s)
		queue_free()

func create_debris(side: int):
	var debris : Asteroid = duplicate()
	var debris_velocity = (transform.x * side) * 100
	
	debris.start_debris(global_position + (transform.x * 10) * side, debris_velocity, side)
	
	get_parent().call_deferred("add_child", debris)

## BUILT-IN

func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	
	if is_debris:
		if debris_side == -1: animated_sprite2d.animation = "debris_left"
		else: animated_sprite2d.animation = "debris_right"
		collision_shape2d.set_deferred("disabled", false)
		health_component.max_health = 2
		hitbox_component.enable_hitbox()
		hurtbox_component.enable_hurtbox()

	animated_sprite2d.scale = Vector2(1.0, 1.0)
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite2d, "scale", Vector2(3.5, 3.5), 1)

func _integrate_forces(physics_state): # screen wrap for the asteroids
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, -80.0, screensize.x + 80.0)  # uses the radius so the asteroid leave the screen completely before tping it
	xform.origin.y = wrap(xform.origin.y, -80.0, screensize.y + 80.0)
	physics_state.transform = xform

## SIGNAL HANDLERS

func _on_health_changed(_health: int) -> void:
	if _health == health_component.max_health: return
	
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
