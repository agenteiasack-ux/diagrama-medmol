extends Control

@onready var count_label: Label = $MainLayout/CountLabel
@onready var ach_list: VBoxContainer = $MainLayout/AchScroll/AchList

var _card_panels: Dictionary = {}


func _ready() -> void:
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)
	EventBus.load_completed.connect(_on_load_completed)
	_build_list()


func _build_list() -> void:
	for child in ach_list.get_children():
		child.queue_free()
	_card_panels.clear()
	for id in AchievementManager.ACHIEVEMENTS:
		_add_card(id)
	_refresh_count()


func _add_card(ach_id: String) -> void:
	var data: Dictionary = AchievementManager.ACHIEVEMENTS[ach_id]
	var is_unlocked: bool = AchievementManager.unlocked.get(ach_id, false)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 70)
	ach_list.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var icon_lbl := Label.new()
	icon_lbl.custom_minimum_size = Vector2(50, 0)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 28)
	icon_lbl.text = "★" if is_unlocked else "☆"
	icon_lbl.add_theme_color_override(
		"font_color", Color(1.0, 0.85, 0.1) if is_unlocked else Color(0.4, 0.4, 0.45)
	)
	hbox.add_child(icon_lbl)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = data["name"] if is_unlocked else "???"
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override(
		"font_color", Color(1.0, 0.95, 0.6) if is_unlocked else Color(0.5, 0.5, 0.55)
	)
	vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = data["desc"] if is_unlocked else "Sigue jugando para descubrirlo"
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override(
		"font_color", Color(0.75, 0.75, 0.8) if is_unlocked else Color(0.4, 0.4, 0.45)
	)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	_card_panels[ach_id] = panel


func _refresh_count() -> void:
	var total := AchievementManager.ACHIEVEMENTS.size()
	var done := AchievementManager.get_unlocked_count()
	count_label.text = "%d / %d logros desbloqueados" % [done, total]


func _on_achievement_unlocked(_id: String, _title: String) -> void:
	_build_list()


func _on_load_completed(_offline: float) -> void:
	_build_list()
