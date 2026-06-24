extends CharacterBody3D

# State machine
enum State { PASSIVE, STANDBY, PATHFIND, ATTACK, DEAD }
var current_state: State = State.PASSIVE

# Variables
@export var detection_range := 20.0
@export var attack_range := 2.2
@export var move_speed := 5.0
@export var max_hp := 5.0

var hp = max_hp
var aggressive = false
var can_attack = true
var has_hit_this_swing = false
var target: Node3D = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var hitbox: CollisionShape3D = $Hitbox


func _ready() -> void:
	# Ensure hp is max on load
	hp = max_hp
	
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
	
	# Default to the player being the target
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		
	if target != null:
		var distance = global_position.distance_to(target.global_position)
		update_state(distance)
		run_state(delta, distance)
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	

# Updates state machine states
func update_state(distance: float):
	if current_state == State.DEAD:
		return
		
	if not aggressive:
		current_state = State.PASSIVE
		return
	
	# If target is dead, return to idle state - Does not reset aggressive flag so if player walks into range follow aggressive logic
	if target !=  null and target.has_method("get_hp") and target.get_hp() <= 0:
		target = null
		current_state = State.STANDBY
		return
	
	match current_state:
		State.PASSIVE:
			current_state = State.STANDBY
		State.STANDBY:
			if distance <= detection_range:
				current_state = State.PATHFIND
		State.PATHFIND:
			if distance <= attack_range:
				current_state = State.ATTACK
			elif distance > detection_range:
				current_state = State.STANDBY
		State.ATTACK:
			if distance > attack_range:
				current_state = State.PATHFIND

# The actual logic for each state in the state machine
func run_state(delta: float, distance: float):
	match current_state:
		State.PASSIVE:
			velocity.x = 0
			velocity.z = 0
		
		State.STANDBY:
			velocity.x = 0
			velocity.z = 0
			
		State.PATHFIND:
			nav_agent.target_position = target.global_position
			
			if nav_agent.is_navigation_finished():
				velocity.x = 0
				velocity.z = 0
			else:
				var next_point = nav_agent.get_next_path_position()
				var direction = (next_point - global_position)
				direction.y = 0
				if direction.length() > 0.01:
					direction = direction.normalized()
					velocity = direction * move_speed
					look_at(global_position + direction, Vector3.UP)
				else:
					velocity = Vector3.ZERO
			
		State.ATTACK:
			velocity.x = 0
			velocity.z = 0
			var attack_direction = (target.global_position - global_position)
			attack_direction.y = 0
			if attack_direction.length() > 0.01:
				look_at(global_position + attack_direction.normalized(), Vector3.UP)
			attack()
			
		State.DEAD:
			velocity.x = 0
			velocity.z = 0
			

# Attack funtion.. note placeholder animation and hitbox timing
func attack():
	if not can_attack:
		return
	can_attack = false
	has_hit_this_swing = false
	
	print("NPC Attacks ", target)
	
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.4).timeout
	attack_hitbox.monitoring = false
	
	await  get_tree().create_timer(2.0).timeout
	can_attack = true
	
# Apply damage
func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	if has_hit_this_swing:
		return
	if body == target and body.has_method("take_damage"):
		has_hit_this_swing = true
		body.take_damage(1)
		
# Take damage
func take_damage(amount: int):
	if hp <= 0:
		return
	aggressive = true
	hp -= amount
	print("Eenemy HP: ", hp)
	if hp <= 0:
		die()

# Die funtion
func die():
	current_state = State.DEAD
	hitbox.disabled = true

# Funtion to set a new target
func set_target(new_target: Node3D):
	target = new_target
