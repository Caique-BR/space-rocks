class_name Dreadnought
extends AnimatableBody2D




@export var laser_scene : PackedScene
@onready var engine_thrust = $EngineSprite
@onready var shield_sprite = $ShieldSprite
@onready var animation = $ShipSprite
@export var health = 3
@export var checkpoints : Array[Vector2] ## 0 = enters screen, 1 = top left, 2 bot left, 3 top right, 4 bot right


var speed = 100
var current_pos : Vector2 = global_position
var tween_move : Tween 
var player : Player
var target = null

func _ready() -> void:
	step_enter_scene()
	var p = get_tree().get_nodes_in_group("player")[0]
	if p is Player: player = p

func move_to(to: Vector2, on_finished: Callable):
	look_at(to)
	
	if tween_move: tween_move.kill()
	
	tween_move = create_tween()
	engine_thrust.show()
	#await get_tree().create_timer(3).timeout
	
	tween_move.tween_property(self, "position", to, 1)
	
	tween_move.finished.connect(on_finished)

func step_enter_scene(): # Boss arrives from outside the top center of the screen and stop at the top mid of the screen
		move_to(checkpoints[0], func(): 
			engine_thrust.hide()
			#Spawn shield droid
			#Spawn saucer
			await get_tree().create_timer(1).timeout
			step_one()
			)

func step_one(): # top left of the screen
	for i in range(checkpoints):
		move_to(checkpoints[i], func(): 
			engine_thrust.hide() # Turns off the engine, cause its not moving
			look_at(player.global_position) # Takes aim at the player
			shield_sprite.hide() # turns off the shield to shoot, is vunlerable at this moment
			
			animation.play("shoot")
			await animation.animation_finished
			#shoot() # Shoot at the player
			animation.play("idle")
			shield_sprite.show() # Turns the shield back on, thus becoming invul again
			
			await get_tree().create_timer(6).timeout
			
			)

func step_two():
	pass;
