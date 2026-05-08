extends Node

const SAVE_PATH := "user://save.json"
const AUTO_SAVE_INTERVAL := 30.0

var _timer: float = 0.0
var _pending_genome: Dictionary = {}


func _process(delta: float) -> void:
	_timer += delta
	if _timer >= AUTO_SAVE_INTERVAL:
		_timer = 0.0
		save()


func save() -> void:
	var data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"resources": ResourceManager.to_dict(),
		"minigames": MiniGameManager.to_dict(),
		"prestige": PrestigeManager.to_dict(),
		"achievements": AchievementManager.to_dict(),
	}
	if GameManager.genome_board:
		data["genome"] = GameManager.genome_board.to_dict()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		EventBus.save_completed.emit()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		EventBus.load_completed.emit(0.0)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		EventBus.load_completed.emit(0.0)
		return
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(text) != OK:
		EventBus.load_completed.emit(0.0)
		return
	var data: Dictionary = json.data
	var saved_time: float = data.get("timestamp", 0)
	var offline_sec: float = Time.get_unix_time_from_system() - saved_time
	offline_sec = clampf(offline_sec, 0.0, 86400.0 * 7.0)
	ResourceManager.from_dict(data.get("resources", {}))
	MiniGameManager.from_dict(data.get("minigames", {}))
	PrestigeManager.from_dict(data.get("prestige", {}))
	AchievementManager.from_dict(data.get("achievements", {}))
	_pending_genome = data.get("genome", {})
	if offline_sec > 5.0:
		_apply_offline_progress(offline_sec)
	EventBus.load_completed.emit(offline_sec)


func get_genome_data() -> Dictionary:
	return _pending_genome


func _apply_offline_progress(seconds: float) -> void:
	for id in ResourceManager.RESOURCE_IDS:
		var rate: float = ResourceManager.rates.get(id, 0.0)
		if rate > 0.0:
			ResourceManager.add_resource(id, rate * seconds)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
