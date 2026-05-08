extends Control

const ProducerRowScene := preload("res://scenes/lab/ProducerRow.tscn")

@onready var resource_grid: GridContainer = $MainLayout/ResourceGrid
@onready var click_btn: Button = $MainLayout/ClickButton
@onready var click_rate_label: Label = $MainLayout/ClickRateLabel
@onready var producer_list: VBoxContainer = $MainLayout/ProducerScroll/ProducerList

const RESOURCE_DISPLAY := {
	"nt":    {"label": "Nt",    "color": Color(0.0, 0.9, 1.0)},
	"adn":   {"label": "ADN",   "color": Color(0.3, 1.0, 0.5)},
	"mrna":  {"label": "ARNm",  "color": Color(1.0, 0.8, 0.2)},
	"prot":  {"label": "Prot",  "color": Color(1.0, 0.5, 0.3)},
	"atp":   {"label": "ATP",   "color": Color(0.7, 0.3, 1.0)},
	"genes": {"label": "Genes", "color": Color(0.3, 0.9, 1.0)},
}

var _amount_labels: Dictionary = {}
var _rate_labels: Dictionary = {}


func _ready() -> void:
	click_btn.pressed.connect(_on_click_pressed)
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.producer_upgraded.connect(_on_producer_upgraded)
	EventBus.producer_unlocked.connect(_on_producer_unlocked)
	EventBus.load_completed.connect(_on_load_completed)
	_build_resource_grid()
	_populate_producers()
	_refresh_all_labels()


func _build_resource_grid() -> void:
	for id in RESOURCE_DISPLAY:
		var info: Dictionary = RESOURCE_DISPLAY[id]
		var cell := VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.add_theme_constant_override("separation", 1)

		var name_lbl := Label.new()
		name_lbl.text = info["label"]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.7))
		cell.add_child(name_lbl)

		var amount_lbl := Label.new()
		amount_lbl.text = "0"
		amount_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		amount_lbl.add_theme_font_size_override("font_size", 15)
		amount_lbl.add_theme_color_override("font_color", info["color"])
		cell.add_child(amount_lbl)
		_amount_labels[id] = amount_lbl

		var rate_lbl := Label.new()
		rate_lbl.text = ""
		rate_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rate_lbl.add_theme_font_size_override("font_size", 10)
		rate_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 0.4))
		cell.add_child(rate_lbl)
		_rate_labels[id] = rate_lbl

		resource_grid.add_child(cell)


func _populate_producers() -> void:
	for child in producer_list.get_children():
		child.queue_free()
	for p in ResourceManager.producers:
		var row: Control = ProducerRowScene.instantiate()
		producer_list.add_child(row)
		row.setup(p.id)


func _on_click_pressed() -> void:
	GameManager.on_main_click()
	var tween := create_tween()
	tween.tween_property(click_btn, "scale", Vector2(0.92, 0.92), 0.06)
	tween.tween_property(click_btn, "scale", Vector2(1.0, 1.0), 0.12)


func _on_resource_changed(resource_id: String, _amount: BigNumber) -> void:
	if _amount_labels.has(resource_id):
		_refresh_resource_label(resource_id)
	if resource_id == "nt":
		_refresh_click_label()


func _on_producer_upgraded(_pid: String, _level: int) -> void:
	_refresh_all_rate_labels()


func _on_producer_unlocked(_pid: String) -> void:
	_refresh_all_rate_labels()


func _on_load_completed(_sec: float) -> void:
	_refresh_all_labels()


func _refresh_all_labels() -> void:
	for id in RESOURCE_DISPLAY:
		_refresh_resource_label(id)
	_refresh_click_label()


func _refresh_resource_label(id: String) -> void:
	if not _amount_labels.has(id):
		return
	_amount_labels[id].text = ResourceManager.resources[id].format()
	var rate: float = ResourceManager.rates.get(id, 0.0)
	if rate > 0.0:
		_rate_labels[id].text = "+%.2f/s" % rate
	else:
		_rate_labels[id].text = ""


func _refresh_all_rate_labels() -> void:
	for id in RESOURCE_DISPLAY:
		var rate: float = ResourceManager.rates.get(id, 0.0)
		if rate > 0.0:
			_rate_labels[id].text = "+%.2f/s" % rate
		else:
			_rate_labels[id].text = ""


func _refresh_click_label() -> void:
	var nt_rate: float = ResourceManager.rates.get("nt", 0.0)
	if nt_rate > 0.0:
		click_rate_label.text = "+%.2f nt/s pasivo | +%.1f nt/click" % [
			nt_rate, GameManager.click_power
		]
	else:
		click_rate_label.text = "+%.1f nt/click" % GameManager.click_power
