extends RigidBody2D

# change the linear/damp and angular/damp later to prefered ships gravity pull

@export var bullet_scente : PackedScene
@export var fire_rate = 0.25 # sets the gun fire rate
@export var engine_power = 500 # Sets the ships speed
@export var spin_power = 8000 # Sets the shipss turn speed
@export var max_shield = 100.0 # shield max health
@export var shield_regen = 5.0 # sheild recharge delay



@onready var radius = int($Sprite2D.texture.get_size().x / 2 * $Sprite2D.scale.x) # makes the screen wrap smoother





signal lives_changed
signal dead
signal shield_changed

enum {INIT, ALIVE, INVUL, DEAD} # "FSM" to manage ships current state

var thrust = Vector2.ZERO # force being applied to the engine
var rotation_dir = 0 # ships turn direction
var can_shoot = true
var state = INIT
var screensize = Vector2.ZERO
var reset_pos = false
var lives = 0: set = set_lives
var shield = 0: set = set_shield


func _ready():
	change_state(ALIVE)
	screensize = get_viewport_rect().size
	$GunCooldown.wait_time = fire_rate

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
	$Exhaust.emitting = false
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		$Exhaust.emitting = true
		thrust = transform.x * engine_power 
		if not $EngineSound.playing: $EngineSound.play()
	else: $EngineSound.stop()
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot: shoot()

func _physics_process(_delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _process(delta): # executes the player input
	get_input()
	shield += shield_regen * delta
	
func _integrate_forces(physics_state): # screenwrap funciton
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius)
	xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform
	if reset_pos: # puts the player on the center of the screen
		physics_state.transform.origin = screensize / 2
		reset_pos = false

func shoot(): 
	if state == INVUL: # cant shoot and be invul at the same time
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scente.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)
	$LaserSound.play()
	
func _on_gun_cooldown_timeout(): # refresh the gun on cooldown end
	can_shoot = true

func set_lives(value): # set the starting lives for the player
	shield = max_shield
	lives = value
	lives_changed.emit(lives) # sends the signal when taking dmg and changes the state depending on lives remaning 
	if lives <= 0:
		change_state(DEAD)
	else:
		change_state(INVUL)

func reset(): # resets the game for the next try
	reset_pos = true
	$Sprite2D.show()
	lives = 3
	change_state(ALIVE)

func _on_invulnerability_timer_timeout(): # time immune after taking dmg
	change_state(ALIVE)

func _on_body_entered(body): # when the contact signal is receieved damages the shield, and explodes the rock
	if body.is_in_group("rocks"):
		shield -= body.size * 25
		body.explode()

func explode(): # player explode animation
	$Explosion.show()
	$Explosion/AnimationPlayer.play("explosion")
	await $Explosion/AnimationPlayer.animation_finished
	$Explosion.hide()

func set_shield(value):
	value = min(value, max_shield)
	shield = value
	shield_changed.emit(shield / max_shield) # sends the raito of shield compared to total shield, so hud can display a porcentage of remaning shield isntead of full value
	if shield <= 0:
		lives -= 1
		explode()
