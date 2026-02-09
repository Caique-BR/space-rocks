class_name Player extends RigidBody2D

signal health_changed(new_health)
signal shield_changed(new_shield)
signal died

@onready var ship_sprite : AnimatedSprite2D = get_node("ShipSprite")
@onready var radius : int
@onready var dash_timer : Timer = get_node("DashTimer")

@onready var shield_component : ShieldComponent = get_node("ShieldComponent")
@onready var hurtbox_component : HurtboxComponent = get_node("HurtboxComponent")
@onready var ship_engine_module : ShipEngineModule = get_node("ShipEngineModule")

@export var engine_power = 2000 # Sets the ships speed
@export var spin_power = 8000 # Sets the shipss turn speed

enum { INIT, ALIVE, INVUL, DEAD } # "FSM" to manage ships current state

var screensize = Vector2.ZERO

var thrust = Vector2.ZERO # Force being applied to the ship engine
var movement_vector : Vector2
var aim_vector : Vector2

var state : int = INIT
var moving : bool = false
var reset_pos : bool = false

## SHIP METHODS

func explode(): # Player explode animation
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()

func reset(): # Resets the game for the next try
	reset_pos = true
	ship_sprite.show()
	change_state(ALIVE)

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
	screensize = get_viewport_rect().size
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

func _integrate_forces(physics_state): # screenwrap
	var xform = physics_state.transform
	
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	
	if reset_pos: # reset player and put on the center of the screen
		physics_state.transform.origin = screensize / 2
		reset_pos = false

## SIGNAL HANDLERS

func _on_health_changed(new_health): # set the starting lives for the player
	change_state(INVUL)
	health_changed.emit(new_health)

func _on_health_depleted() -> void:
	change_state(DEAD)

func _on_shield_changed(new_shield: float):
	shield_changed.emit(new_shield / shield_component.max_shield)

func _on_invulnerability_timer_timeout(): # time immune after taking dmg
	change_state(ALIVE)

func _on_player_input_component_move(_m: Vector2) -> void:
	if _m: moving = true

func _on_player_input_component_aim(a: Vector2) -> void:
	aim_vector = a
