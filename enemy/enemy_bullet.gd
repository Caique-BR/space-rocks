extends Area2D

@export var speed = 1000
@export var damage = 15 # enemy gun damage dealt to players shield

func start(_pos, _dir):
	position = _pos
	rotation = _dir.angle()

func _process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body): # damages the player on contatc and deletes the bullet after
	if body.name == "Player": body.shield -= damage
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited(): # delets the bullet after it leaves the screen
	queue_free()
