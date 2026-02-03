class_name WeaponModule
extends Node2D

@onready var gun_cooldown : Timer = get_node("GunCooldown")

@export var current_weapon : Weapon
var weapons : Array[Weapon]

func _ready() -> void:
	for child in get_children():
		if child is Weapon:
			weapons.append(child)

func _on_shoot() -> void:
	if gun_cooldown.time_left: return
	print("AAAAAAAAAAAAAAA")
	current_weapon.shoot()
	gun_cooldown.start(current_weapon.fire_rate)
