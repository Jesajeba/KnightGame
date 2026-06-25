extends CharacterBody3D

@export var encounter_id: String = "bear_hut"
@export var max_hp: float = 3
@onready var hitbox: CollisionShape3D = $Hitbox

var hp: float

func _ready():
	hp = max_hp

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
		
	move_and_slide()

func take_damage(amount: int, attacker: Node3D = null):
	if hp <= 0:
		return
	hp -= amount
	print("NPC hp: ", hp)
	if hp <= 0:
		die()

func die():
	GameManager.set_flag(encounter_id, "npc_owner_killed", true)
	hitbox.disabled = true
	print("NPC died")
	
func get_hp() -> float:
	return hp
