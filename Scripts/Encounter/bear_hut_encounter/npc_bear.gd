extends CharacterBody3D

enum State {PASSIVE, ALERT, IDLE, PATHFIND, ATTACK, DEAD}

# Variables
@export var encounter_id: String = "bear_hut"
@export var max_hp: float = 3.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var current_state: State = State.PASSIVE
var hp: float
var target: Node3D = null


func _ready():
	hp = max_hp # Set hp to max hp on load
	current_state = State.PASSIVE
	print("Bear ready, loaded state: ", State.keys()[current_state])
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity = get_gravity() * delta * 2.0
	else:
		velocity = Vector3.ZERO
		
	move_and_slide()
	
	
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	print("Bear state: ", State.keys()[current_state], " -> ", State.keys()[new_state])
	current_state = new_state
	
func _on_detection_range_body_entered(body: Node3D) -> void:
	target = body
	print("Body detected: ", body)
	if current_state == State.PASSIVE:
		current_state = State.ALERT
	
func _on_detection_range_body_exited(body: Node3D) -> void:
	target = null
	print("Body left detection range")
	if current_state == State.ALERT:
		current_state = State.PASSIVE

# Taking damage
func take_damage(amount: int):
	if hp <= 0:
		return
	hp -= amount
	print("Bear HP: ", hp)
	if hp <= 0:
		die()

# Dying
func die():
	current_state = State.DEAD
	GameManager.set_flag(encounter_id, "bear_killed", true)
	print("bear died")
