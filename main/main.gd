extends Node

@export var asteroid_scene : PackedScene

@export var hud : HUD
@export var camera : Camera
@export var animation_player : AnimationPlayer

func spawn_asteroid():
	var a : Asteroid = asteroid_scene.instantiate()

	#a.start(trans, vel)
	#a.exploded.connect(self._on_asteroid_exploded)
	#call_deferred("add_child", a)

## BUILT-IN

func _ready():
	CameraControls.camera = camera
	animation_player.play("start")
	
	## DEBUG
	Utilily.start(%UtilityTextBox)

## SIGNAL HANDLERS
