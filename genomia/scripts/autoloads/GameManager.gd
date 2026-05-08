extends Node

var click_power: float = 1.0
var offline_seconds: float = 0.0
var total_clicks: int = 0


func _ready() -> void:
	EventBus.load_completed.connect(_on_load_completed)
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
	pass
