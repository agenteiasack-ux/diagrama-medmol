extends Control

@onready var bg: ColorRect = $BG
@onready var rarity_label: Label = $VBox/RarityLabel
@onready var name_label: Label = $VBox/NameLabel
@onready var effect_label: Label = $VBox/EffectLabel
@onready var selected_overlay: ColorRect = $SelectedOverlay


func setup(gene_id: String, is_selected: bool) -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	var info := GeneCatalog.get_gene(gene_id)
	if info.is_empty():
		return
	var rarity: int = info.get("rarity", 0)
	var rarity_color := GeneCatalog.get_rarity_color(rarity)

	bg.color = Color(rarity_color.r * 0.18, rarity_color.g * 0.18, rarity_color.b * 0.18, 0.95)

	# Left accent strip — colored by rarity
	var strip := get_node_or_null("AccentStrip") as ColorRect
	if strip == null:
		strip = ColorRect.new()
		strip.name = "AccentStrip"
		strip.mouse_filter = MOUSE_FILTER_IGNORE
		strip.anchor_left   = 0.0
		strip.anchor_top    = 0.0
		strip.anchor_right  = 0.0
		strip.anchor_bottom = 1.0
		strip.offset_right  = 4
		add_child(strip)
		move_child(strip, 1)  # Above BG, below VBox
	strip.color = rarity_color

	rarity_label.text = GeneCatalog.get_rarity_name(rarity).to_upper()
	rarity_label.add_theme_color_override("font_color", rarity_color)
	rarity_label.add_theme_font_size_override("font_size", 9)

	name_label.text = info.get("name", gene_id)
	name_label.add_theme_color_override("font_color", Color(0.93, 0.93, 1.0))
	name_label.add_theme_font_size_override("font_size", 13)

	effect_label.text = info.get("effect", "")
	effect_label.add_theme_font_size_override("font_size", 9)

	selected_overlay.visible = is_selected
