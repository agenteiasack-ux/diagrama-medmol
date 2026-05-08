class_name BaseMinigame
extends Control

signal game_completed(rewards: Dictionary)
signal game_canceled

var _time_limit: float = 30.0
var _elapsed: float = 0.0
var _active: bool = false
var _game_id: String = ""


func initialize(game_id: String, time_limit: float) -> void:
	_game_id = game_id
	_time_limit = time_limit


func start() -> void:
	_elapsed = 0.0
	_active = true
	set_process(true)
	_on_start()


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	_on_tick(delta)
	_update_timer_display(_time_limit - _elapsed)
	if _elapsed >= _time_limit:
		_active = false
		_on_time_up()


func _on_start() -> void:
	pass


func _on_tick(_delta: float) -> void:
	pass


func _on_time_up() -> void:
	finish({})


func finish(rewards: Dictionary) -> void:
	_active = false
	game_completed.emit(rewards)


func cancel() -> void:
	_active = false
	game_canceled.emit()


func _update_timer_display(_remaining: float) -> void:
	pass
