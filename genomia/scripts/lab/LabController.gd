extends Control

const ProducerRowScene := preload("res://scenes/lab/ProducerRow.tscn")

@onready var nt_label: Label = $MainLayout/ResourceBar/NtLabel
@onready var adn_label: Label = $MainLayout/ResourceBar/ADNLabel
@onready var mrna_label: Label = $MainLayout/ResourceBar/MRNALabel
@onready var click_btn: Button = $MainLayout/ClickButton
@onready var click_rate_label: Label = $MainLayout/ClickRateLabel
@onready var producer_list: VBoxContainer = $MainLayout/ProducerScroll/ProducerList

const INITIAL_PRODUCERS := ["nt_synthase", "dna_polymerase", "rna_transcriptase"]


func _ready() -> void:
	click_btn.pressed.connect(_on_click_pressed)
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.producer_upgraded.connect(_on_producer_upgraded)
	EventBus.load_completed.connect(_on_load_completed)
	_populate_producers()
	_refresh_labels()


func _populate_producers() -> void:
	for child in producer_list.get_children():
		child.queue_free()
	for pid in INITIAL_PRODUCERS:
		var row: Control = ProducerRowScene.instantiate()
		producer_list.add_child(row)
		row.setup(pid)


func _on_click_pressed() -> void:
	GameManager.on_main_click()
	var tween := create_tween()
	tween.tween_property(click_btn, "scale", Vector2(0.93, 0.93), 0.06)
	tween.tween_property(click_btn, "scale", Vector2(1.0, 1.0), 0.12)


func _on_resource_changed(resource_id: String, _amount: BigNumber) -> void:
	if resource_id in ["nt", "adn", "mrna"]:
		_refresh_labels()


func _on_producer_upgraded(_pid: String, _level: int) -> void:
	_refresh_labels()


func _on_load_completed(_sec: float) -> void:
	_refresh_labels()


func _refresh_labels() -> void:
	nt_label.text = "Nt: %s" % ResourceManager.resources["nt"].format()
	adn_label.text = "ADN: %s" % ResourceManager.resources["adn"].format()
	mrna_label.text = "ARNm: %s" % ResourceManager.resources["mrna"].format()
	var nt_rate := ResourceManager.rates.get("nt", 0.0)
	if nt_rate > 0.0:
		click_rate_label.text = "+%.2f nt/s (pasivo)" % nt_rate
	else:
		click_rate_label.text = "+%.1f nt/click" % GameManager.click_power
