extends Node

const RESOURCE_IDS := [
	"nt", "adn", "mrna", "prot", "atp", "genes", "mutants", "evo_credits"
]

var resources: Dictionary = {}
var rates: Dictionary = {}
var producers: Array = []


class ProducerState:
	var id: String = ""
	var display_name: String = ""
	var description: String = ""
	var level: int = 0
	var base_production: float = 1.0
	var base_cost: float = 10.0
	var cost_multiplier: float = 1.07
	var cycle_time: float = 1.0
	var input_id: String = ""
	var input_per_cycle: float = 0.0
	var output_id: String = ""
	var manager_unlocked: bool = false
	var multiplier: float = 1.0
	var timer: float = 0.0

	func get_cost() -> BigNumber:
		return BigNumber.from_float(base_cost * pow(cost_multiplier, float(level)))

	func get_production_per_cycle() -> float:
		return base_production * float(max(level, 1)) * multiplier * _milestone_bonus()

	func _milestone_bonus() -> float:
		var bonus := 1.0
		for milestone in [10, 25, 50, 100, 200, 300, 400, 500]:
			if level >= milestone:
				bonus *= 2.0
		return bonus

	func get_rate_per_second() -> float:
		if level <= 0 or not manager_unlocked:
			return 0.0
		return get_production_per_cycle() / cycle_time


func _ready() -> void:
	_init_resources()
	_init_producers()


func _init_resources() -> void:
	for id in RESOURCE_IDS:
		resources[id] = BigNumber.zero()
		rates[id] = 0.0


func _init_producers() -> void:
	var defs := [
		{
			"id": "nt_synthase",
			"name": "Nucleotido Sintasa",
			"desc": "Sintetiza nucleotidos libres a partir de materia prima celular.",
			"base_prod": 1.0, "cost": 10.0, "cm": 1.07, "time": 1.0,
			"inp": "", "iamt": 0.0, "out": "nt"
		},
		{
			"id": "dna_polymerase",
			"name": "ADN Polimerasa",
			"desc": "Une nucleotidos para sintetizar hebras de ADN.",
			"base_prod": 0.5, "cost": 150.0, "cm": 1.08, "time": 3.0,
			"inp": "nt", "iamt": 5.0, "out": "adn"
		},
		{
			"id": "rna_transcriptase",
			"name": "ARN Transcriptasa",
			"desc": "Copia el ADN en ARN mensajero para la sintesis proteica.",
			"base_prod": 0.3, "cost": 1500.0, "cm": 1.09, "time": 5.0,
			"inp": "adn", "iamt": 3.0, "out": "mrna"
		},
		{
			"id": "ribosome",
			"name": "Ribosoma",
			"desc": "Traduce el ARNm en cadenas polipeptidicas.",
			"base_prod": 0.2, "cost": 15000.0, "cm": 1.10, "time": 8.0,
			"inp": "mrna", "iamt": 2.0, "out": "prot"
		},
		{
			"id": "mitochondria",
			"name": "Mitocondria",
			"desc": "Genera ATP mediante la cadena de transporte de electrones.",
			"base_prod": 0.1, "cost": 150000.0, "cm": 1.11, "time": 12.0,
			"inp": "prot", "iamt": 2.0, "out": "atp"
		},
		{
			"id": "sequencer",
			"name": "Secuenciador Genomico",
			"desc": "Descifra secuencias geneticas para descubrir nuevos genes.",
			"base_prod": 0.05, "cost": 1500000.0, "cm": 1.12, "time": 20.0,
			"inp": "atp", "iamt": 5.0, "out": "genes"
		},
		{
			"id": "crispr_lab",
			"name": "CRISPR Lab",
			"desc": "Edita genes con precision molecular para crear mutantes.",
			"base_prod": 0.02, "cost": 15000000.0, "cm": 1.15, "time": 30.0,
			"inp": "genes", "iamt": 3.0, "out": "mutants"
		},
	]
	for d in defs:
		var p := ProducerState.new()
		p.id = d["id"]
		p.display_name = d["name"]
		p.description = d["desc"]
		p.base_production = d["base_prod"]
		p.base_cost = d["cost"]
		p.cost_multiplier = d["cm"]
		p.cycle_time = d["time"]
		p.input_id = d["inp"]
		p.input_per_cycle = d["iamt"]
		p.output_id = d["out"]
		producers.append(p)


# --- Tick ---

func tick(delta: float) -> void:
	for p in producers:
		if p.level <= 0 or not p.manager_unlocked:
			continue
		p.timer += delta
		while p.timer >= p.cycle_time:
			p.timer -= p.cycle_time
			_execute_cycle(p)


func _execute_cycle(p: ProducerState) -> void:
	if p.input_id != "":
		var needed := BigNumber.from_float(p.input_per_cycle * float(p.level))
		if not resources[p.input_id].greater_than_or_equal(needed):
			return
		resources[p.input_id] = resources[p.input_id].subtract(needed)
		EventBus.resource_changed.emit(p.input_id, resources[p.input_id])
	var produced := BigNumber.from_float(p.get_production_per_cycle())
	resources[p.output_id] = resources[p.output_id].add(produced)
	EventBus.resource_changed.emit(p.output_id, resources[p.output_id])


# --- API publica ---

func add_resource(id: String, amount: float) -> void:
	if not resources.has(id):
		return
	resources[id] = resources[id].add(BigNumber.from_float(amount))
	EventBus.resource_changed.emit(id, resources[id])


func can_afford_producer(producer_id: String) -> bool:
	var p := get_producer(producer_id)
	if not p:
		return false
	return resources["nt"].greater_than_or_equal(p.get_cost())


func buy_producer(producer_id: String) -> bool:
	var p := get_producer(producer_id)
	if not p:
		return false
	var cost := p.get_cost()
	if not resources["nt"].greater_than_or_equal(cost):
		return false
	resources["nt"] = resources["nt"].subtract(cost)
	p.level += 1
	_recalc_rates()
	EventBus.resource_changed.emit("nt", resources["nt"])
	EventBus.producer_upgraded.emit(producer_id, p.level)
	return true


func get_producer(id: String) -> ProducerState:
	for p in producers:
		if p.id == id:
			return p
	return null


func _recalc_rates() -> void:
	for id in RESOURCE_IDS:
		rates[id] = 0.0
	for p in producers:
		if p.level > 0 and p.manager_unlocked:
			rates[p.output_id] += p.get_rate_per_second()


# --- Guardar / Cargar ---

func to_dict() -> Dictionary:
	var data := {}
	for id in RESOURCE_IDS:
		data[id] = resources[id].to_dict()
	var prod_arr := []
	for p in producers:
		prod_arr.append({
			"id": p.id,
			"level": p.level,
			"timer": p.timer,
			"manager": p.manager_unlocked,
			"multiplier": p.multiplier,
		})
	data["producers"] = prod_arr
	return data


func from_dict(data: Dictionary) -> void:
	for id in RESOURCE_IDS:
		if data.has(id):
			resources[id] = BigNumber.from_dict(data[id])
	if data.has("producers"):
		for pd in data["producers"]:
			var p := get_producer(pd.get("id", ""))
			if p:
				p.level = pd.get("level", 0)
				p.timer = pd.get("timer", 0.0)
				p.manager_unlocked = pd.get("manager", false)
				p.multiplier = pd.get("multiplier", 1.0)
	_recalc_rates()
