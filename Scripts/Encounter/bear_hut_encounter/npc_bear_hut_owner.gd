extends RigidBody3D

@export var encounter_id: String = "bear_hut"

@export var max_hp := 3
var hp := max_hp

@onready var head: RigidBody3D = $Head

const BLOOD_EFFECT = preload("res://Scenes/blood_spray.tscn")

func _ready():
	hp = max_hp
	freeze = true
	head.freeze = true  # stays "attached" visually until death

func take_damage(amount: int, source_position: Vector3 = global_position):
	if hp <= 0:
		return
	hp -= amount
	if hp <= 0:
		die(source_position)
	print("Took Damage")

func die(attack_origin: Vector3 = global_position):
	GameManager.set_flag(encounter_id, "npc_owner_killed", true)
	freeze = false  # body falls
	var direction = (global_position - attack_origin).normalized()
	apply_central_impulse(direction * 4.0 + Vector3.UP * 2.0)
	pop_head(direction)
	
	var blood = BLOOD_EFFECT.instantiate()
	add_child(blood)
	blood.position = Vector3.ZERO
	blood.play()

func pop_head(direction: Vector3):
	head.reparent(get_tree().current_scene, true)  # keeps world position/rotation
	head.freeze = false
	head.apply_central_impulse(direction * 2.0)
	head.apply_torque_impulse(Vector3(randf(), randf(), randf()) * 1.0)
	
	var head_blood = BLOOD_EFFECT.instantiate()
	head.add_child(head_blood)
	head_blood.position = Vector3.ZERO
	head_blood.play()

func _process(delta: float) -> void:
	pass
