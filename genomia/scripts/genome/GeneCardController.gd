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

	bg.color = Color(rarity_color.r * 0.25, rarity_color.g * 0.25, rarity_color.b * 0.25, 0.9)

	rarity_label.text = GeneCatalog.get_rarity_name(rarity).to_upper()
	rarity_label.add_theme_color_override("font_color", rarity_color)

	name_label.text = info.get("name", gene_id)
	name_label.add_theme_color_override("font_color", Color(0.93, 0.93, 1.0))

	effect_label.text = info.get("effect", "")

	selected_overlay.visible = is_selected
