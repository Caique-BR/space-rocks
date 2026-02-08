class_name Dreadnought
extends AnimatableBody2D

@export var ray_beam : PackedScene
@onready var engine_thrust = $EngineSprite
@onready var shield_sprite : AnimatedSprite2D = $ShieldSprite
@onready var ship_sprite = $ShipSprite
@onready var raybeam : Node2D = $RayBeam
@export var checkpoints : Array[Vector2] ## 0 = top left, 1 bot left, 2 top right, 3 bot right

@onready var hitbox : HitboxComponent = get_tree().root.get_node("/root/Main/Dreadnought/RayBeam/HitboxComponent")
var checkpoints_index = 0
var speed = 100
var current_pos : Vector2 = global_position
var player : Player
var target = null
var has_shot = false

var tween_move : Tween 
var tween_damage : Tween 

func move_to(to: Vector2, on_finished: Callable):
	look_at(to)
	
	if tween_move: tween_move.kill()
	
	tween_move = create_tween()
	engine_thrust.show()
	#await get_tree().create_timer(3).timeout
	
	tween_move.tween_property(self, "position", to, 1)
	
	tween_move.finished.connect(on_finished)

func step_enter_scene(): # Boss arrives from outside the top center of the screen and stop at the top mid of the screen
		move_to(Vector2(950, 200), func(): 
			
			engine_thrust.hide()
			#Spawn shield droid
			#Spawn saucer
			await get_tree().create_timer(1).timeout
			#start_routine()
			)

func start_routine(): # top left of the screen
	move_to(checkpoints[checkpoints_index], func(): 
		hitbox.set_collision_layer_value(4, false)
		
		engine_thrust.hide() # Turns off the engine, cause its not moving
		look_at(player.global_position) # Takes aim at the player
		
		shield_sprite.hide() # turns off the shield to shoot, is vunlerable at this moment
		has_shot = false
		ship_sprite.play("shoot")
		await ship_sprite.animation_finished
		has_shot = true
		if has_shot == true: raybeam.hide()
		ship_sprite.play("idle")
		shield_sprite.show() # Turns the shield back on, thus becoming invul again
	
		await get_tree().create_timer(1).timeout
		checkpoints_index += 1 # index managment to loop the 4 positions
		if checkpoints_index == 4: checkpoints_index = 0
		start_routine()
		)

## BUILT-IN

func _ready() -> void:
	step_enter_scene()
	var p = get_tree().get_nodes_in_group("player")[0]
	if p is Player: player = p

## SIGNAL HANDLERS

func _on_ship_sprite_frame_changed() -> void:
	if ship_sprite.animation == "shoot":
		if ship_sprite.frame >= 17 and ship_sprite.frame <= 41:
			rotation = lerp_angle(rotation, rotation + get_angle_to(player.global_position), 0.1)
			raybeam.show()
			
			if ship_sprite.frame % 2: hitbox.set_collision_layer_value(4, true)
			else: hitbox.set_collision_layer_value(4, false)
		else: hitbox.set_collision_layer_value(4, false)

func _on_health_changed(_new_value: int) -> void:
	print("Dreadnougt Health: ", _new_value)

func _on_health_depleted() -> void:
	#queue_free()
	pass

func _on_shield_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		if tween_damage: tween_damage.kill()
		tween_damage = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
		shield_sprite.scale = Vector2(3.1, 3.1)
		ship_sprite.modulate = Color(4.416, 4.416, 4.416)
		tween_damage.tween_property(shield_sprite, "scale", Vector2(3.25, 3.25), 0.5)
		tween_damage.tween_property(shield_sprite, "modulate", Color(1, 1, 1), 0.5)
		
		var projectile = area.get_parent()
		var shield_hit_pos = Vector2(projectile.global_position)
		var collision_normal = transform.x.rotated(transform.x.angle_to(shield_hit_pos)) 
		
		projectile.velocity = projectile.velocity.bounce(collision_normal)
		projectile.rotation = transform.x.angle()
		
