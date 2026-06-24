extends CharacterBody3D

@export var encounter_id: String = "bear_hut"
@export var max_hp: float = 3

var hp: float

func _ready():
	hp = max_hp

func take_damage(amount: int):
	if hp <= 0:
		return
	hp -= amount
	print("NPC hp: ", hp)
	if hp <= 0:
		die()

func die():
	GameManager.set_flag(encounter_id, "npc_owner_killed", true)
	print("NPC died")
