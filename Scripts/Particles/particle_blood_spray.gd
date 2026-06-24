extends Node3D

@onready var blood_spray: GPUParticles3D = $ParticleBloodSpray

func play():
	blood_spray.emitting = true
	await get_tree().create_timer(7.0).timeout
	queue_free()
