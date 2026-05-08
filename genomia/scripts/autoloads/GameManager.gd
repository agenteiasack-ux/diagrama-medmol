extends Node

var click_power: float = 1.0
var offline_seconds: float = 0.0
var total_clicks: int = 0
var genome_board = null  # Set by GenomeBoardController on _ready


func _ready() -> void:
	EventBus.load_completed.connect(_on_load_completed)
	EventBus.prestige_triggered.connect(func(_l, _c): apply_prestige())
	SaveManager.load_game()


func _process(delta: float) -> void:
	ResourceManager.tick(delta)


func _on_load_completed(offline_sec: float) -> void:
	offline_seconds = offline_sec


func on_main_click() -> void:
	ResourceManager.add_resource("nt", click_power)
	total_clicks += 1


func set_click_power(power: float) -> void:
	click_power = power


func apply_prestige() -> void:
	click_power = 1.0


func to_dict() -> Dictionary:
	return {"click_power": click_power, "total_clicks": total_clicks}


func from_dict(data: Dictionary) -> void:
	click_power = data.get("click_power", 1.0)
	total_clicks = data.get("total_clicks", 0)
