class_name WeaponModule
extends Node2D

@onready var gun_cooldown : Timer = get_node("GunCooldown")

@export var current_weapon : Weapon
var weapons : Array[Weapon]

## Methods

func equip_weapon() -> void:
	current_weapon = weapons[0]
	current_weapon.show()

## Built-in

func _ready() -> void:
	for child in get_children():
		if child is Weapon:
			weapons.append(child)
			child.hide()
	if current_weapon:
		current_weapon.show()

## Handlers

func _on_shoot() -> void:
	if gun_cooldown.time_left: return
	if current_weapon:
		current_weapon.shoot()
		gun_cooldown.start(current_weapon.fire_rate)
