extends Area2D

# caique gay

@export var speed = 1000 

var velocity = Vector2.ZERO

func start(_transform): # calls this when a bullets spawns, telling it correct path
	transform = _transform
	velocity = transform.x * speed
	
func _process(delta):
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited(): # delets the bullet when exiting the sceen
	queue_free()

func _on_body_entered(body): # deletes the bullet if collides with rock
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()


func _on_area_entered(area):
	if area.is_in_group("enemies"): area.take_damage(1)
