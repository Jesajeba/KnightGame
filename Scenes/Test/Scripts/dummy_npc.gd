extends CharacterBody3D

var max_hp = 3.0
var hp = max_hp


func _ready() -> void:
	hp = max_hp
	
func take_damage(amount: int, source_position: Vector3 = global_position):
	if hp <= 0:
		return
	hp -= amount
	print("Dummy NPC HP: ", hp)
	
# Support function for attacker to check whether this target is dead or not
func get_hp() -> float:
	return hp
