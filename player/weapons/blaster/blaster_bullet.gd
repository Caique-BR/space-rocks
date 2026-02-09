class_name BlasterBullet
extends Node2D

@onready var bullet_sprite : AnimatedSprite2D = get_node("BulletSprite")
@onready var explosion_sprite : AnimatedSprite2D = get_node("ExplosionSprite")
@onready var hitbox_component : HitboxComponent = get_node("HitboxComponent")

@export var speed = 1000

var velocity = Vector2.ZERO

func start(_transform : Transform2D): # calls this when a bullets spawns, telling it correct path
	transform = _transform
	velocity = transform.x * speed

func explode_bullet(): # Called when bullet hits something
	velocity = Vector2.ZERO

	bullet_sprite.hide()
	explosion_sprite.show()

	explosion_sprite.play("explode")
	await explosion_sprite.animation_finished
	queue_free()

## BUILT-IN

func _process(delta):
	position += velocity * delta

## SIGNAL HANDLERS

func _on_hit(_hurtbox: Variant) -> void:
	hitbox_component.disable_hitbox()
	queue_free()
	#explode_bullet()

func _on_visible_on_screen_notifier_2d_screen_exited(): # delets the bullet when exiting the sceen
	queue_free()
