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
var size : int = 0
var radius : int = 0
var scale_factor : float = 0.2

func start(_position, _velocity, _size): # handles asteroid creation size and speed
	position = _position
	size = _size
	mass = 1.5 * size
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)

func explode(): # asteroid goes boom
	
	collision_shape2d.set_deferred("disabled", true)
	var next_rock_linear_velocity = linear_velocity
	linear_velocity = Vector2.ZERO
	
	angular_velocity = 0 
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	exploded.emit(size, radius, position, next_rock_linear_velocity) # emits the exploded signal for dupping asteroids
	queue_free()

## BUILT-IN

func _ready() -> void:
	animated_sprite2d.scale = (Vector2(4.25, 4.25) * scale_factor * size)
	radius = int(asteroid_texture.get_size().x / 2 * animated_sprite2d.scale.x)
	
	var shape = CircleShape2D.new()
	
	shape.radius = radius
	collision_shape2d.shape = shape
	health_component.health = size
	
	$HitboxComponent/CollisionShape2D.shape = shape.duplicate()

func _integrate_forces(physics_state): # screen wrap for the asteroids
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, 0 - radius, screensize.x + radius)  # uses the radius so the asteroid leave the screen completely before tping it
	xform.origin.y = wrap(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform

## SIGNAL HANDLERS

func _on_health_changed(_health: int) -> void:
	animation_player.play("hurt")

func _on_health_depleted() -> void:
	hurtbox_component.disable_hurtbox()
	explode()
