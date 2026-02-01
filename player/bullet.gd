extends Area2D

@onready var bullet_sprite : Sprite2D = get_node("Sprite2D")
@onready var explosion_sprite : AnimatedSprite2D = get_node("Explosion")

@export var speed = 1000 

var velocity = Vector2.ZERO

func start(_transform : Transform2D, _transform_x: Vector2): # calls this when a bullets spawns, telling it correct path
	transform = _transform
	transform.x = _transform_x
	velocity = transform.x * speed
	
func explode_bullet(): # Called when bullet hits something
	## The bullet disappearing instanly after hitting a target does not give enough response to the player
	## This function guarantees that after hitting a target the bullet will then play a exploding animation and the leaves the screen 
	
	monitorable = false ## Set "monitarable" on bullet to false so other areas/body can't (monitor) detect it
	monitoring = false ## Set "monitoring" on bullet to false so it can't (monitor) detect other areas/body
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

func _on_body_entered(body): # deletes the bullet if collides with asteroid
	if body.is_in_group("asteroids"):
		body.hurt()
		explode_bullet()

func _on_area_entered(area):
	if area.is_in_group("enemies"): 
		area.take_damage(1)
		explode_bullet()
