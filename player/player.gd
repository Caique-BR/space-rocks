class_name Player extends RigidBody2D

signal lives_changed
signal dead
signal shield_changed

# change the linear/damp and angular/damp later to prefered ships gravity pull

@onready var radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x) # makes the screen wrap smoother
@onready var muzzles : Array[Node] = $Muzzles.get_children() # stores both muzzles on a list (array)

@export var bullet_scente : PackedScene
@export var fire_rate = 0.25 # sets the gun fire rate
@export var engine_power = 500 # Sets the ships speed
@export var spin_power = 8000 # Sets the shipss turn speed
@export var max_shield = 100.0 # shield max health
@export var shield_regen = 5.0 # sheild recharge delay

enum { INIT, ALIVE, INVUL, DEAD } # "FSM" to manage ships current state

var screensize = Vector2.ZERO

var thrust = Vector2.ZERO # force being applied to the engine
var rotation_dir = 0 # ships turn direction

var state = INIT
var reset_pos = false
var can_shoot = true
var current_muzzle : int = 0 # index of the current muzzle used as anchor for the next bullet

var lives = 0: set = set_lives
var shield = 0: set = set_shield

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
	lives = 3
	change_state(ALIVE)

func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield / max_shield) # sends the raito of shield compared to total shield, so hud can display a porcentage of remaning shield isntead of full value
	if shield <= 0:
		lives -= 1
		explode()

func set_lives(value): # set the starting lives for the player
	shield = max_shield
	lives = value
	lives_changed.emit(lives) # sends the signal when taking dmg and changes the state depending on lives remaning 
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVUL)

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

func get_input(): # reads the player input and applies it to the ship
	$RearExhaust.emitting = false
	thrust = Vector2.ZERO
	
	if state in [DEAD, INIT]: return 
	
	if Input.is_action_pressed("thrust"):
		$RearExhaust.emitting = true
		thrust = transform.x * engine_power 
		if not $EngineSound.playing: $EngineSound.play()
	else: $EngineSound.stop()

	if Input.is_action_pressed("shoot") and can_shoot: shoot()

######################## BUILT-IN METHODS

func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

func _process(delta): # executes the player input
	get_input()
	shield += shield_regen * delta

func _physics_process(_delta):
	constant_force = thrust
	
	var mouse_pos = get_global_mouse_position()
	
	rotation += get_angle_to(mouse_pos)

func _integrate_forces(physics_state): # screenwrap
	var xform = physics_state.transform
	
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	
	if reset_pos: # reset player and put on the center of the screen
		physics_state.transform.origin = screensize / 2
		reset_pos = false

######################## SIGNAL HANDLERS

func _on_gun_cooldown_timeout(): # refresh the gun on cooldown end
	can_shoot = true

func _on_invulnerability_timer_timeout(): # time immune after taking dmg
	change_state(ALIVE)

func _on_body_entered(body): # when the contact signal is receieved damages the shield, and explodes the rock
	if body.is_in_group("rocks"):
		shield -= body.size * 25
		body.explode()
