extends CharacterBody3D

# State machine
enum State { PASSIVE, STANDBY, PATHFIND, ATTACK, DEAD }
var current_state: State = State.PASSIVE

# Variables
@export var detection_range: float = 20.0
@export var attack_range: float = 2.4
@export var move_speed: float = 5.0
@export var max_hp: float = 5.0
@export var damage: float = 1.0

var hp = max_hp
var aggressive: bool = false
var can_attack: bool = true
var has_hit_this_swing: bool = false
var target: Node3D = null
var last_state: State = current_state

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var attack_hitbox: Area3D = $AttackHitbox
@onready var hitbox: CollisionShape3D = $Hitbox


# Start of logic
func _ready() -> void:
	# Ensure hp is max on load
	hp = max_hp
	
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.0
		
	if target != null:
		var distance = global_position.distance_to(target.global_position)
		update_state(distance)
		print_state_if_changed()
		run_state()
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	
	
func print_state_if_changed() -> void:
	if current_state != last_state:
		print(name, " state: ", State.keys()[last_state], " -> ", State.keys()[current_state])
		last_state = current_state
	
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
		aggressive = false
		current_state = State.PASSIVE
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
# Pass delta as argument once lerping rotation for look at stuff
func run_state():
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
		body.take_damage(damage)
		
# Take damage
func take_damage(amount: float, attacker: Node3D = null):
	if hp <= 0:
		return
	aggressive = true
	hp -= amount
	print("Eenemy HP: ", hp)
	if attacker != null and target == null:
		target = attacker
	if hp <= 0:
		die()

# Die funtion
func die():
	current_state = State.DEAD
	hitbox.disabled = true

# Funtion to set a new target
func set_target(new_target: Node3D):
	target = new_target
