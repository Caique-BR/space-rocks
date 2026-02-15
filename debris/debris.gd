class_name Debris
extends RigidBody2D

@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent
@export var drop_component : DropComponent
@export var collision_shape_2d : Node2D 

func start(trans: Transform2D, vel: Vector2) -> void:
	transform = trans
	linear_velocity = vel
	angular_velocity = randf_range(-PI, PI)

func stop_motion() -> void:
	freeze = true
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", Vector2.ZERO)
	collision_shape_2d.set_deferred("disabled", true)
