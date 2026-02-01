class_name Asteroid extends RigidBody2D

signal exploded

@onready var animated_sprite2d : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var collision_shape : CollisionShape2D = get_node("CollisionShape2D")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")


@onready var asteroid_texture : Texture2D = load("res://assets/asteroid/asteroid.png")

var screensize = Vector2.ZERO
var size : int = 0
var radius : int = 0
var scale_factor : float = 0.2

var health : int = 0 ## Health represents the asteroid's current health amount
## Asteroids are big chunks of rocks and having it exploding after a single shot fells unnatural
## By having a health, we can make asteroids more resistent based on its size
## The initial health will uses the value of `size` passed on the `start` function
## If an asteroid have 3 of size, it will have to take 3 hits before exploding

func start(_position, _velocity, _size): # handles asteroid creation size and speed
	position = _position
	size = _size
	mass = 1.5 * size
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	health = _size

func hurt(): ## Handles the asteroid current's state of health
	health -= 1 ## If the function `hurt` was called it means that something hit the asteroid, so we start by subtracting -1 of the asteroid's health
	## This allows health to hit 0 as value what we handle below on the code
	
	if health == 0: ## If health is equal to 0 after subtracting we can then start exploding and duplicating the rock, if necessary
		explode() ## Calls explodes
	else: ## `health` then is still greater than 0
		animation_player.play("hurt") ## Only play hurt animation and asteroid remains alive 

func explode(): # asteroid goes boom
	
	collision_shape.set_deferred("disabled", true)
	var next_rock_linear_velocity = linear_velocity
	linear_velocity = Vector2.ZERO
	
	angular_velocity = 0 
	animated_sprite2d.play("explode")
	await animated_sprite2d.animation_finished
	
	exploded.emit(size, radius, position, next_rock_linear_velocity) # emits the exploded signal for dupping asteroids
	queue_free()

func _ready() -> void:
	animated_sprite2d.scale = (Vector2(4.25, 4.25) * scale_factor * size)
	radius = int(asteroid_texture.get_size().x / 2 * animated_sprite2d.scale.x)
	
	var shape = CircleShape2D.new()
	var hit_box_shape = CircleShape2D.new()
	shape.radius = radius
	hit_box_shape.radius = radius
	$CollisionShape2D.shape = shape
	
	$HitboxComponent/CollisionShape2D.shape = hit_box_shape

func _integrate_forces(physics_state): # screen wrap for the asteroids
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, 0 - radius, screensize.x + radius)  # uses the radius so the asteroid leave the screen completely before tping it
	xform.origin.y = wrap(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
