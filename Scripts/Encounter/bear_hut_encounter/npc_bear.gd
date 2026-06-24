extends CharacterBody3D

enum State {PASSIVE, ALERT, STANDBY, PATHFIND, ATTACK, DEAD}

# Variables
@export var encounter_id: String = "bear_hut"
@export var chase_range: float = 15.0
@export var attack_range: float = 1.5
@export var move_speed: float = 3.0
@export var max_hp: float = 3.0
@export var turn_speed: float = 8.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_hitbox: Area3D = $AttackHitbox

var current_state : State = State.PASSIVE
var hp: float = max_hp
var aggressive: bool = false
var can_attack: bool = true
var has_hit_this_swing: bool = false
var target: Node3D = null
var targets_in_range: Array[Node3D] = []


func _ready():
	hp = max_hp # Set hp to max hp on load
	
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity = get_gravity() * delta * 2.0
	move_and_slide()
	
	if current_state == State.ALERT:
		_face_target(delta)
		evaluate_state()
	
	
func evaluate_state() -> void:
	if target == null:
		if current_state != State.PASSIVE:
			change_state(State.PASSIVE)
		return
		
	var distance: float = global_position.distance_to(target.global_position)
	
	if distance <= attack_range:
		change_state(State.ATTACK)
	elif distance <= chase_range:
		change_state(State.PATHFIND)
	else:
		if current_state != State.PASSIVE:
			change_state(State.ALERT)
	
	
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
	GameManager.set_flag(encounter_id, "bear_killed", true)
	print("bear died")

func _face_target(delta: float) -> void:
	if target == null:
		return
	var look_pos: Vector3 = target.global_position
	look_pos.y = global_position.y
	if look_pos.distance_to(global_position) < 0.01:
		return

	var target_basis: Basis = Basis.looking_at(look_pos - global_position, Vector3.UP)
	var current_quat: Quaternion = quaternion
	var target_quat: Quaternion = target_basis.get_rotation_quaternion()
	quaternion = current_quat.slerp(target_quat, delta * turn_speed)


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	print("Bear state: ", State.keys()[current_state], " -> ", State.keys()[new_state])
	current_state = new_state

# change between passive and idle in detection area
func _on_detection_area_body_entered(body: Node3D) -> void:
	if not body.is_in_group("entity"):
		return
	if current_state == State.PASSIVE:
		change_state(State.ALERT)


func _on_detection_area_body_exited(body: Node3D) -> void:
	if not body.is_in_group("entity"):
		return
	if current_state == State.ALERT:
		change_state(State.PASSIVE)


# Set target in chase area
func _on_chase_area_body_entered(body: Node3D) -> void:
	if not body.is_in_group("entity"):
		return
	if not targets_in_range.has(body):
		targets_in_range.append(body)
	target = body
	print("Target acquired: ", body)


func _on_chase_area_body_exited(body: Node3D) -> void:
	if not body.is_in_group("entity"):
		return
	targets_in_range.erase(body)
	if target == body:
		target = targets_in_range.back() if targets_in_range.size() > 0 else null
		print("Target lost, new target: ", target)
