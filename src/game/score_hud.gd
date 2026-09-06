class_name ScoreHud extends Control

var container: HBoxContainer
var player_cards: Dictionary = {}
var target_wins: int = 3

const PLAYER_COLORS: Dictionary = {
	1: Color(0.25, 0.75, 1.0, 1.0), # Peter (Azul / Cyan)
	2: Color(1.0, 0.65, 0.2, 1.0),  # Kenny (Naranja)
	3: Color(0.35, 0.9, 0.45, 1.0), # Bestian (Verde)
	4: Color(0.95, 0.35, 0.85, 1.0) # Wyrm (Magenta / Púrpura)
}

func _init() -> void:
	_ensure_ui()

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_ui()

func _ensure_ui() -> void:
	if container == null:
		config_ui()

func config_ui() -> void:
	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.07, 0.11, 0.85)
	panel_style.border_color = Color(0.3, 0.4, 0.55, 0.6)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_top = 4.0
	panel_style.content_margin_bottom = 4.0
	top_panel.add_theme_stylebox_override("panel", panel_style)
	
	top_panel.layout_mode = 1
	top_panel.anchors_preset = Control.PRESET_CENTER_TOP
	top_panel.anchor_left = 0.5
	top_panel.anchor_right = 0.5
	top_panel.anchor_top = 0.0
	top_panel.anchor_bottom = 0.0
	top_panel.offset_left = 0.0
	top_panel.offset_right = 0.0
	top_panel.offset_top = 6.0
	top_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	top_panel.grow_vertical = Control.GROW_DIRECTION_END
	
	container = HBoxContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 14)
	
	top_panel.add_child(container)
	add_child(top_panel)

func setup_players(player_list: Array, max_wins: int = 3) -> void:
	_ensure_ui()
	target_wins = max_wins
	
	for child in container.get_children():
		child.queue_free()
	player_cards.clear()
	
	for p in player_list:
		var p_id: int = 0
		var p_name: String = ""
		
		if p is Dictionary:
			p_id = int(p.get("id", p.get("_id", 0)))
			p_name = str(p.get("nickname", "Jugador " + str(p_id)))
		elif "nickname" in p and "_id" in p:
			p_id = int(p._id)
			p_name = str(p.nickname)
		else:
			continue
		
		var card: PanelContainer = _create_player_card(p_id, p_name, 0, target_wins)
		container.add_child(card)
		player_cards[p_id] = card

func _create_player_card(p_id: int, p_name: String, current_score: int, max_wins: int) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var base_color: Color = PLAYER_COLORS.get(p_id, Color(0.8, 0.8, 0.8, 1.0))
	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.1, 0.15, 0.9)
	card_style.border_color = base_color
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(6)
	card_style.content_margin_left = 8.0
	card_style.content_margin_right = 8.0
	card_style.content_margin_top = 2.0
	card_style.content_margin_bottom = 2.0
	card.add_theme_stylebox_override("panel", card_style)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	
	var name_lbl: Label = Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = p_name
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", base_color)
	name_lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	name_lbl.add_theme_constant_override("outline_size", 2)
	
	var score_lbl: Label = Label.new()
	score_lbl.name = "ScoreLabel"
	score_lbl.text = _format_score_text(current_score, max_wins)
	score_lbl.add_theme_font_size_override("font_size", 12)
	score_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8, 1.0))
	score_lbl.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	score_lbl.add_theme_constant_override("outline_size", 2)
	
	hbox.add_child(name_lbl)
	hbox.add_child(score_lbl)
	card.add_child(hbox)
	
	return card

func _format_score_text(current_score: int, max_wins: int) -> String:
	var stars: String = ""
	for i in range(max_wins):
		if i < current_score:
			stars += "★"
		else:
			stars += "☆"
	return "[%d/%d %s]" % [current_score, max_wins, stars]

func update_scores(scores: Dictionary, max_wins: int = -1) -> void:
	if max_wins > 0:
		target_wins = max_wins
	
	for p_id in scores.keys():
		var int_id: int = int(p_id)
		if player_cards.has(int_id):
			var card: PanelContainer = player_cards[int_id]
			var score_lbl: Label = card.find_child("ScoreLabel", true, false)
			if score_lbl:
				var current_score: int = int(scores[p_id])
				score_lbl.text = _format_score_text(current_score, target_wins)

func highlight_winner(winner_id: int) -> void:
	if not player_cards.has(winner_id) or not is_inside_tree():
		return
	var card: PanelContainer = player_cards[winner_id]
	card.pivot_offset = Vector2(card.size.x / 2.0, card.size.y / 2.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(1.25, 1.25), 0.25)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.25)
