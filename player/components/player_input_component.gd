class_name PlayerInputComponent
extends Node

@export var player : Player;
@export var rear_exhaust : CPUParticles2D
@export var engine_sound : AudioStreamPlayer

func get_input(): # reads the player input and applies it to the ship
	rear_exhaust.emitting = false
	player.thrust = Vector2.ZERO
	if player.state in [player.DEAD, player.INIT]: return 
	
	if Input.is_action_pressed("thrust"):
		rear_exhaust.emitting = true
		
		if Input.is_action_pressed("boost"):
			player.thrust = player.transform.x * (player.engine_power + 500)
		else:
			player.thrust = player.transform.x * player.engine_power 
			
		if not engine_sound.playing: engine_sound.play()
	else: engine_sound.stop()

	if Input.is_action_pressed("shoot") and player.can_shoot: player.shoot()

## BUILT-IN

func _process(_delta: float) -> void:
	get_input()
