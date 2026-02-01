class_name Laser
extends Node2D

@onready var bullet_sprite : Sprite2D = get_node("Sprite2D")
@onready var explosion_sprite : AnimatedSprite2D = get_node("Explosion")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")

@export var speed = 1000 

var velocity = Vector2.ZERO

func start(layer: int, _transform : Transform2D, _transform_x: Vector2): # calls this when a bullets spawns, telling it correct path
	transform = _transform
	transform.x = _transform_x
	velocity = transform.x * speed
	hitbox_component.set_collision_layer_value(layer, true)

func explode_bullet(): # Called when bullet hits something
	## The bullet disappearing instanly after hitting a target does not give enough response to the player
	## This function guarantees that after hitting a target the bullet will then play a exploding animation and the leaves the screen 
	
	## This prevents bullet from hitting a target again while on exploding animation
	
	velocity = Vector2.ZERO ## We set velocity to Vector.ZERO so the bullet ceases moving
	
	bullet_sprite.hide()
	explosion_sprite.show()
	## We hide the bullet sprite and start showing the explosion to start the animation
	
	explosion_sprite.play("explode") ## Tells the explosion sprite to start animating
	await explosion_sprite.animation_finished ## Wait for the animation to finish
	queue_free() ## Safely remove bullet from the scene
	
func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited(): # delets the bullet when exiting the sceen
	queue_free()
