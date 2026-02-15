class_name ExperienceCluster
extends Node2D

@export var collision_shape2d : CollisionShape2D;
@export var pickup_scene : PackedScene;
@export var experience_pickup : ExperiencePickupData;

var total_exp : int = 0
var radius : int = 0

func start(r: int, e: int) -> void:
	radius = r
	total_exp = e
	experience_pickup = experience_pickup.duplicate()
	
	create_cluster()

func create_cluster() -> void:
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision_shape2d.shape = shape
	
	for idx in range(total_exp / 10):
		var exp_pickup : Pickup = pickup_scene.instantiate()
		experience_pickup.experience_amount = total_exp / 10
		exp_pickup.pickup_data = experience_pickup
		
		var rand_x = sin(randf()) * randf_range(-radius, radius)
		var rand_y = cos(randf()) * randf_range(-radius, radius)
		
		var tween : Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(exp_pickup, "position", Vector2(rand_x, rand_y), 1)
		
		add_child(exp_pickup)
