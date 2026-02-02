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
var tween_spawn : Tween

func start(_position, _velocity): # handles asteroid creation size and speed
	position = _position
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)

func explode(): # asteroid goes boom
	
	collision_shape2d.set_deferred("disabled", true)
	linear_velocity = Vector2.ZERO
	
	angular_velocity = 0 
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	exploded.emit() # emits the exploded signal for dupping asteroids
	queue_free()

## BUILT-IN

func _ready() -> void:
	animated_sprite2d.scale = Vector2(1.0, 1.0)
	tween_spawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_spawn.tween_property(animated_sprite2d, "scale", Vector2(3.5, 3.5), 1)

func _integrate_forces(physics_state): # screen wrap for the asteroids
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, -80.0, screensize.x + 80.0)  # uses the radius so the asteroid leave the screen completely before tping it
	xform.origin.y = wrap(xform.origin.y, -80.0, screensize.y + 80.0)
	physics_state.transform = xform

## SIGNAL HANDLERS

func _on_health_changed(_health: int) -> void:
	animation_player.play("hurt")
	animated_sprite2d.frame += 1
	animated_sprite2d.scale = Vector2(3.25, 3.25)
	tween_spawn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_spawn.tween_property(animated_sprite2d, "scale", Vector2(3.5, 3.5), 0.5)

func _on_health_depleted() -> void:
	animation_player.play("hurt")
	CameraControls.camera.screen_shake(10, 0.25)
	hurtbox_component.disable_hurtbox()
	explode()
