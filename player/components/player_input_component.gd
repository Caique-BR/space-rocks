class_name PlayerInputComponent
extends Node

signal shoot
signal dash_left
signal dash_right

@export var player : Player;
@export var rear_exhaust : CPUParticles2D
@export var engine_sound : AudioStreamPlayer

func get_input(): # reads the player input and applies it to the ship
	rear_exhaust.emitting = false
	player.thrust = Vector2.ZERO
	if player.state in [player.DEAD, player.INIT]: return 
	
	if Input.is_action_pressed("thrust"):
		rear_exhaust.emitting = true
		player.thrust = player.transform.x * player.engine_power
			
		if not engine_sound.playing: engine_sound.play()
	else: engine_sound.stop()

	if Input.is_action_pressed("shoot"): emit_signal("shoot")
	if Input.is_action_just_pressed("dash_left"): emit_signal("dash_left")
	if Input.is_action_just_pressed("dash_right"): emit_signal("dash_right")

## BUILT-IN

func _process(_delta: float) -> void:
	get_input()
