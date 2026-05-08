extends Node

const COOLDOWNS := {
	"dna_replication":    120.0,
	"pcr_rhythm":         180.0,
	"gel_electrophoresis": 240.0,
	"gatk_sequencing":    300.0,
	"crispr_cut":         600.0,
}

const UNLOCK_ORDER := [
	"dna_replication",
	"pcr_rhythm",
	"gel_electrophoresis",
	"gatk_sequencing",
	"crispr_cut",
]

var _remaining: Dictionary = {}
var _completions: Dictionary = {}


func _ready() -> void:
	for id in COOLDOWNS:
		_remaining[id] = 0.0
		_completions[id] = 0


func _process(delta: float) -> void:
	for id in COOLDOWNS:
		if _remaining[id] > 0.0:
			_remaining[id] = maxf(_remaining[id] - delta, 0.0)
			if _remaining[id] == 0.0:
				EventBus.minigame_cooldown_ready.emit(id)


func is_unlocked(id: String) -> bool:
	var idx := UNLOCK_ORDER.find(id)
	if idx <= 0:
		return true
	return _completions.get(UNLOCK_ORDER[idx - 1], 0) >= 1


func is_available(id: String) -> bool:
	return is_unlocked(id) and _remaining.get(id, 0.0) <= 0.0


func on_completed(id: String) -> void:
	_completions[id] = _completions.get(id, 0) + 1
	_remaining[id] = COOLDOWNS.get(id, 120.0) * PrestigeManager.get_cooldown_multiplier()


func get_remaining_text(id: String) -> String:
	var sec := int(_remaining.get(id, 0.0))
	if sec <= 0:
		return "Disponible"
	return "%d:%02d" % [sec / 60, sec % 60]


func to_dict() -> Dictionary:
	return {
		"remaining": _remaining.duplicate(),
		"completions": _completions.duplicate(),
	}


func from_dict(data: Dictionary) -> void:
	for id in COOLDOWNS:
		_remaining[id] = data.get("remaining", {}).get(id, 0.0)
		_completions[id] = data.get("completions", {}).get(id, 0)
