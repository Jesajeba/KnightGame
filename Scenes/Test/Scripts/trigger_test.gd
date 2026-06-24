extends Area3D

@export var npc_attacker: Node3D
@export var npc_target: Node3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("npc_attacker is: ", npc_attacker, " | script: ", npc_attacker.get_script())
		npc_attacker.aggressive = true
		npc_attacker.set_target(npc_target)
