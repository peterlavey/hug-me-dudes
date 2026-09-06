class_name SpontaneousCombustion extends Disease

const _name: String = "SpontaneousCombustion"
var Fire = preload("res://particles/Fire.tscn")
var fire: CPUParticles2D
const LIFE_EXPECTANCY: float = 6.0

func _ready() -> void:
	fire = Fire.instantiate()
	fire.z_index = 2
	start_effects()
	start(LIFE_EXPECTANCY)

func dead() -> void:
	afflicted.dead()
	if afflicted._animation:
		afflicted._animation.modulate = Color('#333333')

func remove_effects() -> void:
	if afflicted and afflicted._animation:
		afflicted._animation.modulate = Color("ffffff")
	if fire and is_instance_valid(fire):
		fire.queue_free()

func start_effects() -> void:
	if afflicted and afflicted._animation:
		afflicted._animation.modulate = Color("ff6633")
	if afflicted and fire:
		afflicted.add_child(fire)
