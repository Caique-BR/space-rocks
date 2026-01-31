extends Area2D

@export var bullet_scene : PackedScene
@export var speed = 150 # enemy speed
@export var rotation_speed = 120
@export var health = 3 # enemy health
@export var bullet_spread = 0.2 
@export var damage = 15 # damage dealt by enemy bullet to player shield

var follow = PathFollow2D.new()
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3 # chooses a random sprite of the 3 to spawn as the enemy
	var path = $EnemyPaths.get_children()[randi() % $EnemyPaths.get_child_count()] # chooses a random preset path for the enemy to follow
	path.add_child(follow)
	follow.loop = false # it loops the path by default, so we set to false making it a one shot only

func _physics_process(delta): # enemy movement and deletion on path end
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1: queue_free()  # despawns the enemy on path end

func shoot(): # aims and adds spread to the gun before shooting
	$ShootSound.play()
	var dir = global_position.direction_to(target.global_position) # "finds" the player current possition
	dir = dir.rotated(randf_range(-bullet_spread, bullet_spread)) # adds a spread to the bullet path as a balacing tool
	var b = bullet_scene.instantiate() 
	get_tree().root.add_child(b)
	b.start(global_position, dir)

func shoot_pulse(n, delay): # full auto gun for the enemy, as n in number of shots per "trigger" pull, and delay as time between bullets fired
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func _on_gun_cooldown_timeout(): # choose one or another
	#shoot() 
	shoot_pulse(3, 0.15)

func take_damage(amount):
	health -= amount
	$AnimationPlayer.play("flash")
	if health <= 0: explode()
	
func explode(): # triggers when hit, destroys the enemy ship
	$ExplosionSound.play()
	speed = 0
	$GunCooldown.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()

func _on_body_entered(body): # explodes when colliding with the player, maybe make it explodes on rocks too?
	if body.is_in_group("rocks"): return
	explode()
	body.shield -= 50
