class_name WeaponModule
extends Node2D

signal recoiled

@onready var gun_cooldown : Timer = get_node("GunCooldown")

@export var current_weapon : Weapon
var weapons : Array[Weapon]

func _ready() -> void:
	for child in get_children():
		if child is Weapon:
			weapons.append(child)
			child.hide()
	current_weapon.show()

func _on_shoot() -> void:
	if gun_cooldown.time_left: return
	current_weapon.shoot()
	if current_weapon.recoil: recoiled.emit(current_weapon.recoil)
	gun_cooldown.start(current_weapon.fire_rate)
