class_name SpontaneousCombustion extends Disease

const _name: String = "SpontaneousCombustion"
var Fire = preload("res://particles/Fire.tscn")
var fire: GPUParticles2D
const LIFE_EXPECTANCY: float = 6.0

func _ready() -> void:
	fire = Fire.instantiate()
	start_effects()
	start(LIFE_EXPECTANCY)

func dead() -> void:
	afflicted.dead()
	afflicted._animation.modulate = Color('#333333')

func remove_effects() -> void:
	if fire and is_instance_valid(fire):
		fire.queue_free()

func start_effects() -> void:
	afflicted.add_child(fire)
