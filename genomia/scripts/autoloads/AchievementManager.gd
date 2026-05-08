extends Node

const ACHIEVEMENTS := {
	"primer_nt":         {"name": "Primer Nucleotido",   "desc": "Genera tu primer nucleotido"},
	"primer_adn":        {"name": "ADN Inicial",          "desc": "Genera tu primer ADN"},
	"primer_mrna":       {"name": "ARN Mensajero",        "desc": "Transcribe tu primer mARN"},
	"primer_prot":       {"name": "Primera Proteina",     "desc": "Sintetiza tu primera proteina"},
	"primer_atp":        {"name": "Energia!",             "desc": "Produce tu primer ATP"},
	"primer_gen":        {"name": "Gen Descubierto",      "desc": "Descubre tu primer gen"},
	"primer_mutante":    {"name": "Mutacion",             "desc": "Crea tu primer mutante"},
	"primer_productor":  {"name": "Laboratorio Activo",   "desc": "Compra tu primer productor"},
	"tres_productores":  {"name": "En Expansion",         "desc": "Desbloquea 3 productores distintos"},
	"todos_productores": {"name": "Lab Completo",         "desc": "Desbloquea los 7 productores"},
	"primer_minijuego":  {"name": "Minijuego!",           "desc": "Completa un minijuego"},
	"todos_minijuegos":  {"name": "Versatil",             "desc": "Completa los 5 tipos de minijuego"},
	"mini_50":           {"name": "Cientifico Dedicado",  "desc": "Completa 50 minijuegos en total"},
	"nt_100":            {"name": "Nucleo x100",          "desc": "Acumula 100 nucleotidos a la vez"},
	"adn_1k":            {"name": "ADN x1000",            "desc": "Acumula 1000 unidades de ADN"},
	"genes_20":          {"name": "Banco Genico",         "desc": "Acumula 20 genes"},
	"merge_10":          {"name": "Maestro del Merge",    "desc": "Fusiona genes 10 veces"},
	"primer_prestige":   {"name": "Evolucion I",          "desc": "Realiza tu primera Evolucion"},
	"prestige_3":        {"name": "Evolucion III",        "desc": "Evoluciona 3 veces"},
	"prestige_5":        {"name": "Tycoon Genetico",      "desc": "Alcanza el nivel de Evolucion 5"},
}

var unlocked: Dictionary = {}
var _minigame_types_done: Array = []
var _total_minigames: int = 0
var _merge_count: int = 0


func _ready() -> void:
	for id in ACHIEVEMENTS:
		unlocked[id] = false
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.producer_upgraded.connect(_on_producer_upgraded)
	EventBus.genes_merged.connect(_on_genes_merged)
	EventBus.mutant_created.connect(_on_mutant_created)
	EventBus.minigame_completed.connect(_on_minigame_completed)
	EventBus.prestige_triggered.connect(_on_prestige_triggered)


func _unlock(id: String) -> void:
	if unlocked.get(id, false):
		return
	unlocked[id] = true
	EventBus.achievement_unlocked.emit(id, ACHIEVEMENTS[id]["name"])


func _on_resource_changed(res_id: String, amount: BigNumber) -> void:
	match res_id:
		"nt":
			_unlock("primer_nt")
			if amount.greater_than_or_equal(BigNumber.from_float(100.0)):
				_unlock("nt_100")
		"adn":
			_unlock("primer_adn")
			if amount.greater_than_or_equal(BigNumber.from_float(1000.0)):
				_unlock("adn_1k")
		"mrna":
			_unlock("primer_mrna")
		"prot":
			_unlock("primer_prot")
		"atp":
			_unlock("primer_atp")
		"genes":
			_unlock("primer_gen")
			if amount.greater_than_or_equal(BigNumber.from_float(20.0)):
				_unlock("genes_20")
		"mutants":
			_unlock("primer_mutante")


func _on_producer_upgraded(_producer_id: String, _new_level: int) -> void:
	var count := 0
	for p in ResourceManager.producers:
		if p.level >= 1:
			count += 1
	if count >= 1: _unlock("primer_productor")
	if count >= 3: _unlock("tres_productores")
	if count >= 7: _unlock("todos_productores")


func _on_genes_merged(_result_id: String) -> void:
	_merge_count += 1
	if _merge_count >= 10:
		_unlock("merge_10")


func _on_mutant_created(_mutant_id: String) -> void:
	_unlock("primer_mutante")


func _on_minigame_completed(game_id: String, _reward: Dictionary) -> void:
	_total_minigames += 1
	_unlock("primer_minijuego")
	if not _minigame_types_done.has(game_id):
		_minigame_types_done.append(game_id)
	if _minigame_types_done.size() >= 5:
		_unlock("todos_minijuegos")
	if _total_minigames >= 50:
		_unlock("mini_50")


func _on_prestige_triggered(new_level: int, _credits: int) -> void:
	if new_level >= 1: _unlock("primer_prestige")
	if new_level >= 3: _unlock("prestige_3")
	if new_level >= 5: _unlock("prestige_5")


func get_unlocked_count() -> int:
	var n := 0
	for id in unlocked:
		if unlocked[id]:
			n += 1
	return n


func to_dict() -> Dictionary:
	return {
		"unlocked": unlocked.duplicate(),
		"merge_count": _merge_count,
		"total_minigames": _total_minigames,
		"minigame_types_done": _minigame_types_done.duplicate(),
	}


func from_dict(data: Dictionary) -> void:
	var u: Dictionary = data.get("unlocked", {})
	for id in ACHIEVEMENTS:
		unlocked[id] = u.get(id, false)
	_merge_count = data.get("merge_count", 0)
	_total_minigames = data.get("total_minigames", 0)
	_minigame_types_done = data.get("minigame_types_done", []).duplicate()
