extends Control

@onready var level_label: Label = $MainLayout/StatsBox/LevelLabel
@onready var credits_label: Label = $MainLayout/StatsBox/CreditsLabel
@onready var threshold_label: Label = $MainLayout/ThresholdLabel
@onready var mutants_label: Label = $MainLayout/MutantsLabel
@onready var prestige_btn: Button = $MainLayout/PrestigeButton
@onready var upgrade_grid: GridContainer = $MainLayout/UpgradeScroll/UpgradeGrid

var _upgrade_buttons: Dictionary = {}
var _refresh_timer: float = 0.0


func _ready() -> void:
	prestige_btn.pressed.connect(_on_prestige_pressed)
	EventBus.prestige_triggered.connect(_on_prestige_triggered)
	EventBus.resource_changed.connect(_on_resource_changed)
	_build_upgrades()
	_refresh_display()


func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer >= 0.5:
		_refresh_timer = 0.0
		_refresh_prestige_button()


func _build_upgrades() -> void:
	for child in upgrade_grid.get_children():
		child.queue_free()
	_upgrade_buttons.clear()
	for id in PrestigeManager.UPGRADES:
		_add_upgrade_card(id)


func _add_upgrade_card(upgrade_id: String) -> void:
	var data: Dictionary = PrestigeManager.UPGRADES[upgrade_id]

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 130)
	upgrade_grid.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = data["name"]
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = data["desc"]
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "%d EC" % data["cost"]
	cost_lbl.add_theme_font_size_override("font_size", 14)
	cost_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(cost_lbl)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, 46)
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
	vbox.add_child(btn)

	_upgrade_buttons[upgrade_id] = btn
	_update_upgrade_button(upgrade_id)


func _update_upgrade_button(upgrade_id: String) -> void:
	var btn: Button = _upgrade_buttons.get(upgrade_id)
	if not is_instance_valid(btn):
		return
	if PrestigeManager.purchased.get(upgrade_id, false):
		btn.text = "Adquirido"
		btn.disabled = true
		btn.modulate = Color(0.4, 0.9, 0.4)
	elif PrestigeManager.evo_credits < PrestigeManager.UPGRADES[upgrade_id]["cost"]:
		btn.text = "Sin EC"
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6)
	else:
		btn.text = "Comprar"
		btn.disabled = false
		btn.modulate = Color(1.0, 1.0, 1.0)


func _refresh_display() -> void:
	level_label.text = "Nivel Evolucion: %d" % PrestigeManager.prestige_level
	credits_label.text = "Creditos Evolutivos: %d EC" % PrestigeManager.evo_credits
	var threshold := PrestigeManager.get_prestige_threshold()
	threshold_label.text = "Evolucion requiere %d mutantes" % threshold
	var mutants: BigNumber = ResourceManager.resources.get("mutants", BigNumber.zero())
	mutants_label.text = "Tienes: %s mutantes" % mutants.format()
	_refresh_prestige_button()
	for id in _upgrade_buttons:
		_update_upgrade_button(id)


func _refresh_prestige_button() -> void:
	prestige_btn.disabled = not PrestigeManager.can_prestige()
	if PrestigeManager.can_prestige():
		prestige_btn.text = "EVOLUCIONAR (+%d EC)" % PrestigeManager.get_credits_on_prestige()
		prestige_btn.modulate = Color(0.4, 1.0, 0.6)
	else:
		prestige_btn.text = "EVOLUCIONAR (faltan mutantes)"
		prestige_btn.modulate = Color(0.7, 0.7, 0.7)


func _on_prestige_pressed() -> void:
	PrestigeManager.do_prestige()


func _on_prestige_triggered(_new_level: int, _credits: int) -> void:
	_refresh_display()


func _on_resource_changed(res_id: String, _amount: BigNumber) -> void:
	if res_id == "mutants" or res_id == "evo_credits":
		_refresh_display()


func _on_upgrade_pressed(upgrade_id: String) -> void:
	if PrestigeManager.buy_upgrade(upgrade_id):
		_refresh_display()
