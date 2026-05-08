extends Node

const UPGRADES := {
	"nucleo_veloz":    {"name": "Nucleo Veloz",        "cost": 1,  "desc": "+25% produccion de Nucleotidos"},
	"polim_xl":        {"name": "Polimerasa XL",       "cost": 1,  "desc": "+25% produccion de ADN"},
	"transcr_pro":     {"name": "Transcriptasa Pro",   "cost": 2,  "desc": "+25% produccion de mARN"},
	"ribos_elite":     {"name": "Ribosoma Elite",      "cost": 2,  "desc": "+25% produccion de Proteinas"},
	"mito_plus":       {"name": "Mitocondria Plus",    "cost": 3,  "desc": "+25% produccion de ATP"},
	"gen_expresado":   {"name": "Gen Expresado",       "cost": 3,  "desc": "+50% Genes de minijuegos"},
	"crispr_mejorado": {"name": "CRISPR Mejorado",     "cost": 4,  "desc": "-25% cooldowns de minijuegos"},
	"memoria_gen":     {"name": "Memoria Genetica",    "cost": 5,  "desc": "Conserva 10% de recursos al evolucionar"},
	"prest_acelerado": {"name": "Prestige Acelerado",  "cost": 5,  "desc": "+10% produccion por nivel de Evolucion"},
	"evol_suprema":    {"name": "Evolucion Suprema",   "cost": 10, "desc": "x2 toda la produccion"},
}

var prestige_level: int = 0
var evo_credits: int = 0
var purchased: Dictionary = {}

var _prestige_available_emitted: bool = false


func _ready() -> void:
	for id in UPGRADES:
		purchased[id] = false
	EventBus.resource_changed.connect(_on_resource_changed)


func _on_resource_changed(res_id: String, _amount: BigNumber) -> void:
	if res_id != "mutants":
		return
	if can_prestige() and not _prestige_available_emitted:
		_prestige_available_emitted = true
		EventBus.prestige_available.emit()
	elif not can_prestige():
		_prestige_available_emitted = false


func get_prestige_threshold() -> int:
	return 3 + prestige_level * 2


func can_prestige() -> bool:
	var mutants: BigNumber = ResourceManager.resources.get("mutants", BigNumber.zero())
	return mutants.greater_than_or_equal(BigNumber.from_float(float(get_prestige_threshold())))


func get_credits_on_prestige() -> int:
	return 1 + prestige_level


func do_prestige() -> void:
	if not can_prestige():
		return
	var credits := get_credits_on_prestige()
	evo_credits += credits
	prestige_level += 1
	_prestige_available_emitted = false
	var keep_fraction := 0.1 if purchased.get("memoria_gen", false) else 0.0
	ResourceManager.reset_for_prestige(keep_fraction)
	EventBus.prestige_triggered.emit(prestige_level, credits)


func buy_upgrade(id: String) -> bool:
	if not UPGRADES.has(id) or purchased.get(id, false):
		return false
	var cost: int = UPGRADES[id]["cost"]
	if evo_credits < cost:
		return false
	evo_credits -= cost
	purchased[id] = true
	EventBus.resource_changed.emit("evo_credits", BigNumber.from_float(float(evo_credits)))
	return true


func get_production_multiplier(output_id: String) -> float:
	var mult := 1.0
	if purchased.get("evol_suprema", false):
		mult *= 2.0
	if purchased.get("prest_acelerado", false) and prestige_level > 0:
		mult *= 1.0 + float(prestige_level) * 0.1
	match output_id:
		"nt":   if purchased.get("nucleo_veloz", false):   mult *= 1.25
		"adn":  if purchased.get("polim_xl", false):       mult *= 1.25
		"mrna": if purchased.get("transcr_pro", false):    mult *= 1.25
		"prot": if purchased.get("ribos_elite", false):    mult *= 1.25
		"atp":  if purchased.get("mito_plus", false):      mult *= 1.25
	return mult


func get_cooldown_multiplier() -> float:
	return 0.75 if purchased.get("crispr_mejorado", false) else 1.0


func get_gene_minigame_bonus() -> float:
	return 1.5 if purchased.get("gen_expresado", false) else 1.0


func to_dict() -> Dictionary:
	return {
		"prestige_level": prestige_level,
		"evo_credits": evo_credits,
		"purchased": purchased.duplicate(),
	}


func from_dict(data: Dictionary) -> void:
	prestige_level = data.get("prestige_level", 0)
	evo_credits = data.get("evo_credits", 0)
	var p: Dictionary = data.get("purchased", {})
	for id in UPGRADES:
		purchased[id] = p.get(id, false)
