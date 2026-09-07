class_name CharacterSprite extends AnimatedSprite2D

const DEFAULT_SPRITE_PATH: String = "res://sprites/character/idle.png"

var _opaque_rects_cache: Dictionary = {}

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

static func compute_texture_opaque_rect(texture: Texture2D, region: Rect2 = Rect2()) -> Rect2:
	if texture == null:
		return Rect2()
	
	var img: Image = null
	var target_region: Rect2 = region
	
	if texture is AtlasTexture:
		var atlas_tex: AtlasTexture = texture as AtlasTexture
		if atlas_tex.atlas != null:
			img = atlas_tex.atlas.get_image()
			if target_region == Rect2():
				target_region = atlas_tex.region
	else:
		img = texture.get_image()
		if target_region == Rect2() and img != null:
			target_region = Rect2(0, 0, img.get_width(), img.get_height())
	
	if img == null or target_region.size.x <= 0 or target_region.size.y <= 0:
		return Rect2()
	
	var frame_img: Image = Image.create_empty(int(target_region.size.x), int(target_region.size.y), false, img.get_format())
	frame_img.blit_rect(
		img,
		Rect2i(int(target_region.position.x), int(target_region.position.y), int(target_region.size.x), int(target_region.size.y)),
		Vector2i.ZERO
	)
	var used: Rect2i = frame_img.get_used_rect()
	return Rect2(float(used.position.x), float(used.position.y), float(used.size.x), float(used.size.y))

func get_opaque_rect_for_animation(anim_name: String = "Idle") -> Rect2:
	if _opaque_rects_cache.has(anim_name):
		return _opaque_rects_cache[anim_name]
	
	if sprite_frames == null:
		_setup_frames()
	
	if sprite_frames == null or not sprite_frames.has_animation(anim_name):
		return Rect2()
	
	var frame_count: int = sprite_frames.get_frame_count(anim_name)
	if frame_count == 0:
		return Rect2()
	
	var combined_rect: Rect2 = Rect2()
	var first: bool = true
	
	for i in range(frame_count):
		var tex: Texture2D = sprite_frames.get_frame_texture(anim_name, i)
		var rect: Rect2 = compute_texture_opaque_rect(tex)
		if rect.size.x > 0 and rect.size.y > 0:
			if first:
				combined_rect = rect
				first = false
			else:
				combined_rect = combined_rect.merge(rect)
	
	_opaque_rects_cache[anim_name] = combined_rect
	return combined_rect

func get_collision_shape_data(state: String = "INITIAL") -> Dictionary:
	return calculate_collision_data_for_node(self, state)

static func calculate_collision_data_for_node(node: AnimatedSprite2D, state: String = "INITIAL") -> Dictionary:
	var target_anim: String = "Idle"
	if state == "DEAD" or state == "Dead":
		target_anim = "Dead"
	
	var sf: SpriteFrames = node.sprite_frames
	if sf == null and node is CharacterSprite:
		(node as CharacterSprite)._setup_frames()
		sf = node.sprite_frames
	
	var opaque_rect: Rect2 = Rect2()
	if node is CharacterSprite:
		opaque_rect = (node as CharacterSprite).get_opaque_rect_for_animation(target_anim)
		if opaque_rect.size == Vector2.ZERO and target_anim != "Idle":
			opaque_rect = (node as CharacterSprite).get_opaque_rect_for_animation("Idle")
	elif sf != null:
		var anim_to_check: String = target_anim if sf.has_animation(target_anim) else ("Idle" if sf.has_animation("Idle") else "")
		if anim_to_check != "":
			var count: int = sf.get_frame_count(anim_to_check)
			var first: bool = true
			for i in range(count):
				var tex: Texture2D = sf.get_frame_texture(anim_to_check, i)
				var rect: Rect2 = compute_texture_opaque_rect(tex)
				if rect.size.x > 0 and rect.size.y > 0:
					if first:
						opaque_rect = rect
						first = false
					else:
						opaque_rect = opaque_rect.merge(rect)
	
	# Fallback si no se detecta contenido opaco
	if opaque_rect.size == Vector2.ZERO:
		return {
			"size": Vector2(32, 50),
			"position": Vector2(0.7, 2.2)
		}
	
	var frame_size: Vector2 = Vector2(32, 32)
	if sf != null:
		var anim_for_size: String = target_anim if sf.has_animation(target_anim) else "Idle"
		if sf.has_animation(anim_for_size) and sf.get_frame_count(anim_for_size) > 0:
			var tex: Texture2D = sf.get_frame_texture(anim_for_size, 0)
			if tex is AtlasTexture:
				frame_size = (tex as AtlasTexture).region.size
			elif tex != null:
				frame_size = tex.get_size()
	
	var top_left: Vector2 = node.offset - (frame_size / 2.0) if node.centered else node.offset
	var local_rect: Rect2 = Rect2(top_left + opaque_rect.position, opaque_rect.size)
	
	var scaled_pos: Vector2 = local_rect.position * node.scale
	var scaled_size: Vector2 = local_rect.size * node.scale
	var center: Vector2 = scaled_pos + scaled_size / 2.0
	
	if state == "DEAD" or state == "Dead":
		var dead_height: float = scaled_size.y * (22.0 / 50.0)
		var floor_bottom_y: float = center.y + (scaled_size.y / 2.0)
		var dead_center_y: float = floor_bottom_y - (dead_height / 2.0)
		var dead_width: float = max(scaled_size.x, scaled_size.y * 0.8)
		return {
			"size": Vector2(dead_width, dead_height),
			"position": Vector2(center.x, dead_center_y)
		}
	
	return {
		"size": scaled_size,
		"position": center
	}
