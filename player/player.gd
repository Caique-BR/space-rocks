class_name Player extends RigidBody2D

signal health_changed
signal shield_changed
signal dead

# change the linear/damp and angular/damp later to prefered ships gravity pull

@onready var radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x) # makes the screen wrap smoother
@onready var muzzles : Array[Node] = $Muzzles.get_children() # stores both muzzles on a list (array)

@export var bullet_scente : PackedScene
@export var fire_rate = 0.25 # sets the gun fire rate
@export var engine_power = 500 # Sets the ships speed
@export var spin_power = 8000 # Sets the shipss turn speed

enum { INIT, ALIVE, INVUL, DEAD } # "FSM" to manage ships current state

var screensize = Vector2.ZERO

var thrust = Vector2.ZERO # force being applied to the engine
var rotation_dir = 0 # ships turn direction

var state = INIT
var reset_pos = false
var can_shoot = true
var current_muzzle : int = 0 # index of the current muzzle used as anchor for the next bullet

######################## SHIP METHODS

func shoot(): 
	if state == INVUL: return # can't shoot and be invulnerable at the same time

	can_shoot = false
	
	var b = bullet_scente.instantiate()
	get_tree().root.add_child(b)
	
	var mouse_pos : Vector2 = get_global_mouse_position()
	var final_transform : Transform2D = muzzles[current_muzzle].global_transform
	var final_position : Vector2 = muzzles[current_muzzle].global_position
	var final_transform_x : Vector2 = (mouse_pos - final_position).normalized()
	
	b.start(final_transform, final_transform_x)

	current_muzzle = 1 - current_muzzle

	$GunCooldown.start()
	$LaserSound.play()

func explode(): # player explode animation
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()

func reset(): # resets the game for the next try
	reset_pos = true
	$Sprite2D.show()
	change_state(ALIVE)

func change_state(new_state): # code for the "FSM", uses the match to determ the state of the ship
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = .5 
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate.a = 1
		INVUL:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = .5 # modulate changes the opacity of the sprite, when half transparent the player is immune to dmg
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.hide()
			linear_velocity = Vector2.ZERO
			dead.emit()
			$EngineSound.stop()
	state = new_state

######################## BUILT-IN METHODS

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

func _physics_process(_delta):
	constant_force = thrust
	
	var mouse_pos = get_global_mouse_position()
	var new_rotatation = rotation + get_angle_to(mouse_pos)
	rotation = lerp_angle(rotation, new_rotatation, 0.06)

func _integrate_forces(physics_state): # screenwrap
	var xform = physics_state.transform
	
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	
	if reset_pos: # reset player and put on the center of the screen
		physics_state.transform.origin = screensize / 2
		reset_pos = false

####################### SIGNAL HANDLERS

func _on_health_changed(_old_health, new_health): # set the starting lives for the player
	if new_health <= 0:
		change_state(DEAD)
	else:
		change_state(INVUL)
	health_changed.emit(new_health)

func _on_shield_changed(new_shield: float):
	shield_changed.emit(new_shield)

func _on_gun_cooldown_timeout(): # refresh the gun on cooldown end
	can_shoot = true

func _on_invulnerability_timer_timeout(): # time immune after taking dmg
	change_state(ALIVE)
