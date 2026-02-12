class_name Player extends RigidBody2D

signal health_changed(health_ratio)
signal shield_changed(shield_ratio)
signal died

enum { INIT, ALIVE, INVUL, DEAD }

@export var ship_sprite : AnimatedSprite2D
@export var radius : int

@export var animation_player : AnimationPlayer
@export var health_component : HealthComponent
@export var shield_component : ShieldComponent
@export var hurtbox_component : HurtboxComponent

@export var ship_engine_module : ShipEngineModule

@export var engine_power = 2000
@export var spin_power = 8000

var thrust = Vector2.ZERO
var movement_vector : Vector2
var aim_vector : Vector2

var state : int = INIT
var moving : bool = false
var damaged : bool = false
var tween_damage : Tween

## SHIP METHODS

func explode(): # Player explode animation
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()

func change_state(new_state): # Code for the "FSM", uses the match to determ the state of the ship
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			ship_sprite.modulate.a = .5 
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
			ship_sprite.modulate.a = 1
			show()
			hurtbox_component.enable_hurtbox()
			set_deferred("freeze", false)
		INVUL:
			$CollisionShape2D.set_deferred("disabled", true)
			ship_sprite.modulate.a = 0.5
			hurtbox_component.disable_hurtbox()
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			hide()
			set_deferred("freeze", true)
			died.emit()
			$EngineSound.stop()
			hurtbox_component.disable_hurtbox()
	state = new_state

## BUILT-IN METHODS

func _ready():
	change_state(ALIVE)
	radius = int(ship_sprite.sprite_frames.get_frame_texture("default", 0).get_size().x / 2 * ship_sprite.scale.x)

func _physics_process(_delta):
	if not moving and aim_vector:
		rotation = lerp_angle(rotation, aim_vector.angle(), 0.1)
	
	if state != INVUL and moving:
		constant_force = transform.x * ship_engine_module.current_engine.power
		if ship_engine_module.current_thrust:
			rotation = lerp_angle(rotation, ship_engine_module.current_thrust.angle(), 0.1)
	else:
		constant_force = Vector2.ZERO
	moving = false

## SIGNAL HANDLERS

func _on_health_changed(new_health): # set the starting lives for the player
	change_state(INVUL)
	health_changed.emit(new_health / health_component.max_health)
	print(new_health / health_component.max_health)

func _on_health_depleted() -> void:
	change_state(DEAD)

func _on_shield_changed(new_shield: float):
	shield_changed.emit(new_shield / shield_component.max_shield)

func _on_invulnerability_timer_timeout(): # time immune after taking dmg
	change_state(ALIVE)

func _on_shield_regen_timer_timeout() -> void:
	pass
	
func _on_player_input_component_move(_m: Vector2) -> void:
	if _m: moving = true

func _on_player_input_component_aim(a: Vector2) -> void:
	aim_vector = a

func _on_damage_taken(_total: int, from: Vector2) -> void:
	var damage_direction = (global_position - from).normalized()
	animation_player.play("hurt")
	
	ship_sprite.scale = Vector2(2.5, 2.5)
	
	if tween_damage: tween_damage.kill()
	tween_damage = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_damage.tween_property(ship_sprite, "scale", Vector2(2.1, 2.1), 1)
	
