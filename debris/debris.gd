class_name Debris
extends RigidBody2D

@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent

func start(pos, vel) -> void:
	position = pos
	linear_velocity = vel
	angular_velocity = randf_range(-PI, PI)

## BUILT-IN

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
