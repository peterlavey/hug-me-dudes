class_name CharacterSprite extends AnimatedSprite2D

const DEFAULT_SPRITE_PATH: String = "res://sprites/character/idle.png"

func _ready() -> void:
	_setup_frames()

func _setup_frames() -> void:
	if sprite_frames == null or not sprite_frames.has_animation("Idle") or sprite_frames.get_frame_count("Idle") == 0:
		var generated_frames: SpriteFrames = build_frames_from_spritesheet(DEFAULT_SPRITE_PATH)
		if generated_frames != null:
			sprite_frames = generated_frames
	
	if animation == "" or animation == "default":
		animation = "Idle"
	play(animation)

static func build_frames_from_spritesheet(path: String) -> SpriteFrames:
	if not ResourceLoader.exists(path):
		return null
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		return null
	
	var sf: SpriteFrames = SpriteFrames.new()
	var w: int = texture.get_width()
	var h: int = texture.get_height()
	
	# Si cada imagen es cuadrada en la tira (por ejemplo 64x64 o 32x32), el ancho del frame coincide con la altura
	var frame_size: int = h if h > 0 else 64
	var count: int = int(w / frame_size) if frame_size > 0 else 1
	if count <= 0:
		count = 1
		frame_size = w
	
	var frames: Array[AtlasTexture] = []
	for i in range(count):
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_size, 0, frame_size, h)
		frames.append(atlas)
	
	var anim_configs: Dictionary = {
		"Idle": { "loop": true, "speed": 10.0 },
		"Run": { "loop": true, "speed": 10.0 },
		"Kick": { "loop": false, "speed": 10.0 },
		"Dead": { "loop": true, "speed": 8.0 }
	}
	
	for anim_name in anim_configs.keys():
		var cfg: Dictionary = anim_configs[anim_name]
		if sf.has_animation(anim_name):
			sf.clear(anim_name)
		else:
			sf.add_animation(anim_name)
		sf.set_animation_loop(anim_name, bool(cfg["loop"]))
		sf.set_animation_speed(anim_name, float(cfg["speed"]))
		for atlas_frame in frames:
			sf.add_frame(anim_name, atlas_frame)
	
	return sf
