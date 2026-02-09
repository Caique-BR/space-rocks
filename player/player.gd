class_name Player extends RigidBody2D

signal health_changed(new_health)
signal shield_changed(new_shield)
signal died

@onready var rear_exhaust : CPUParticles2D = get_node("RearExhaust")
@onready var dash_timer : Timer = get_node("DashTimer")
@onready var ship_sprite : AnimatedSprite2D = get_node("ShipSprite")
@onready var shield_component : ShieldComponent = get_node("ShieldComponent")
@onready var radius : int

@export var engine_power = 2000 # Sets the ships speed
@export var spin_power = 8000 # Sets the shipss turn speed

enum { INIT, ALIVE, INVUL, DEAD } # "FSM" to manage ships current state

var screensize = Vector2.ZERO

var thrust = Vector2.ZERO # Force being applied to the engine
var rotation_dir : int = 0 # Ships turn direction
var movement_vector : Vector2
var aim_vector : Vector2

var state = INIT
var reset_pos = false

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
		INVUL:
			$CollisionShape2D.set_deferred("disabled", true)
			ship_sprite.modulate.a = .5 # modulate changes the opacity of the sprite, when half transparent the player is immune to dmg
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			ship_sprite.hide()
			linear_velocity = Vector2.ZERO
			died.emit()
			$EngineSound.stop()
	state = new_state

## BUILT-IN METHODS

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	radius = int(ship_sprite.sprite_frames.get_frame_texture("default", 0).get_size().x / 2 * ship_sprite.scale.x)
	
func _physics_process(_delta):
	if movement_vector:
		rear_exhaust.emitting = true
		thrust = transform.x * engine_power
		rotation = lerp_angle(rotation, movement_vector.angle(), 0.1)
	else:
		rear_exhaust.emitting = false
		thrust = Vector2.ZERO
	
	if not movement_vector and aim_vector:
		rotation = lerp_angle(rotation, aim_vector.angle(), 0.1)
	
	constant_force = thrust
	
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

func _on_player_input_component_move(m: Vector2) -> void:
	movement_vector = m

func _on_player_input_component_aim(a: Vector2) -> void:
	aim_vector = a
