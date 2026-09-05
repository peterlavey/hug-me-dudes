class_name FulminatingDiarrhea extends Disease

const _name: String = "FulminatingDiarrhea"
var Diarrhea = preload("res://particles/Diarrhea.tscn")
var diarrhea: GPUParticles2D
const LIFE_EXPECTANCY: float = 5.0

func _ready() -> void:
	diarrhea = Diarrhea.instantiate()
	start_effects()
	start(LIFE_EXPECTANCY)

func dead() -> void:
	afflicted.dead()
	afflicted._animation.modulate = Color("2d7550")

func remove_effects() -> void:
	afflicted._animation.modulate = Color("ffffff")
	if diarrhea and is_instance_valid(diarrhea):
		diarrhea.queue_free()

func start_effects() -> void:
	afflicted._animation.modulate = Color("4d732a")
	afflicted.add_child(diarrhea)
