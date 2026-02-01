class_name Saucer
extends Node2D

@export var laser_scene : PackedScene
@export var speed = 150 # enemy speed
@export var rotation_speed = 120
@export var bullet_spread = 0.2 
@export var damage = 15 # damage dealt by enemy bullet to player shield

@onready var enemy_sprite : Sprite2D = get_node("Sprite2D")
@onready var enemy_paths : Node = get_node("EnemyPaths")
@onready var shoot_sound : AudioStreamPlayer = get_node("ShootSound")
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")

var follow = PathFollow2D.new()
var target = null

func _ready():
	enemy_sprite.frame = randi() % 3 # chooses a random sprite of the 3 to spawn as the enemy
	var path = enemy_paths.get_children()[randi() % enemy_paths.get_child_count()] # chooses a random preset path for the enemy to follow
	path.add_child(follow)
	follow.loop = false # it loops the path by default, so we set to false making it a one shot only

func _process(delta): # enemy movement and deletion on path end
	rotation += deg_to_rad(rotation_speed) * delta
	follow.progress += speed * delta
	position = follow.global_position
	if follow.progress_ratio >= 1: queue_free()  # despawns the enemy on path end

func shoot(): # aims and adds spread to the gun before shooting
	shoot_sound.play()
	
	var final_transform = Transform2D(transform) # "finds" the player current possition
	var final_dir = global_position.direction_to(target.global_position) # "finds" the player current possition
	final_dir = final_dir.rotated(randf_range(-bullet_spread, bullet_spread)) # adds a spread to the bullet path as a balacing tool
	
	var laser : Laser = laser_scene.instantiate() 
	get_tree().root.add_child(laser)
	laser.start(1, final_transform, final_dir)

func shoot_pulse(n, delay): # full auto gun for the enemy, as n in number of shots per "trigger" pull, and delay as time between bullets fired
	for i in n:
		shoot()
		await get_tree().create_timer(delay).timeout

func _on_gun_cooldown_timeout(): # choose one or another
	#shoot() 
	shoot_pulse(3, 0.15)
	
func explode(): # triggers when hit, destroys the enemy ship
	$ExplosionSound.play()
	speed = 0
	$GunCooldown.stop()
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()

## SIGNAL HANDLERS

func _on_health_changed(_new_value) -> void:
	animation_player.play("flash")

func _on_health_depleted() -> void:
	explode()
