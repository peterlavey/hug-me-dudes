class_name CustomCamera extends Camera2D

const DEFAULT_ZOOM: Vector2 = Vector2(1.0, 1.0)
const WINNER_ZOOM: Vector2 = Vector2(2.3, 2.3)
const DEFAULT_TRANSITION_TIME: float = 1.2

var _target: Node2D = null
var _tween: Tween

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0

func _process(delta: float) -> void:
	if _target and is_instance_valid(_target) and get_parent() != _target:
		global_position = global_position.lerp(_target.global_position, 8.0 * delta)

func focus_on_winner(winner: Node2D, target_zoom: Vector2 = WINNER_ZOOM, duration: float = DEFAULT_TRANSITION_TIME) -> void:
	_target = winner
	enabled = true
	
	if _tween and _tween.is_valid():
		_tween.kill()
	
	if get_parent() != winner:
		if get_parent() != null:
			get_parent().remove_child(self)
		winner.add_child(self)
	
	position = Vector2(0, -12)
	zoom = DEFAULT_ZOOM
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0
	
	if is_inside_tree():
		make_current()
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_CUBIC)
		_tween.set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "zoom", target_zoom, duration)
	else:
		zoom = target_zoom

func zoom_in(new_offset: Vector2 = Vector2.ZERO) -> void:
	transition_camera(WINNER_ZOOM, new_offset)

func zoom_out(new_offset: Vector2 = Vector2.ZERO) -> void:
	transition_camera(DEFAULT_ZOOM, new_offset)

func transition_camera(new_zoom: Vector2, new_offset: Vector2 = Vector2.ZERO, duration: float = DEFAULT_TRANSITION_TIME) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "zoom", new_zoom, duration)
	_tween.parallel().tween_property(self, "offset", new_offset, duration)