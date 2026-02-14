class_name ShipEngineModule
extends Node2D

@export var engine_sound : AudioStreamPlayer
@export var current_engine : ShipEngine

var current_thrust : Vector2 = Vector2.ZERO
var movement_vector : Vector2 = Vector2.ZERO

## Built-in
 
func _ready() -> void:
	if current_engine:
		current_engine.show()

func _physics_process(_delta: float) -> void:
	if movement_vector:
		current_thrust = movement_vector * current_engine.power
		current_engine.thrust()
		if not engine_sound.playing: 
			engine_sound.play()
	else:
		engine_sound.stop()
		current_thrust = Vector2.ZERO
		current_engine.idle()
	movement_vector = Vector2.ZERO

## Handlers

func _on_player_input_component_move(m: Vector2) -> void:
	movement_vector = m
