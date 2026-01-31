extends RigidBody2D

signal exploded # for dupping the rocks when shoot

var screensize = Vector2.ZERO
var size
var radius
var scale_factor = 0.2

func start(_position, _velocity, _size): # handles rock creation size and speed
	position = _position
	size = _size
	mass = 1.5 * size
	$RockImage.scale = Vector2.ONE * scale_factor * size
	radius = int($RockImage.texture.get_size().x / 2 * $RockImage.scale.x)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)
	$Explosion.scale = Vector2.ONE * 0.75 * size

func _integrate_forces(physics_state): # screen wrap for the rocks
	var xform = physics_state.transform
	xform.origin.x = wrap(xform.origin.x, 0 - radius, screensize.x + radius)  # uses the radius so the rock leave the screen completely before tping it
	xform.origin.y = wrap(xform.origin.y, 0 - radius, screensize.y + radius)
	physics_state.transform = xform

func explode(): # rock goes boom
	$CollisionShape2D.set_deferred("disabled", true)
	$RockImage.hide()
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()
	exploded.emit(size, radius, position, linear_velocity) # emits the exploded signal for dupping rocks
	angular_velocity = 0 
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
