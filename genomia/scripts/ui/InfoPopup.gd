extends AcceptDialog

@onready var title_label: Label = $VBox/TitleLabel
@onready var process_label: Label = $VBox/ProcessLabel
@onready var input_label: Label = $VBox/InputLabel
@onready var output_label: Label = $VBox/OutputLabel
@onready var stats_label: Label = $VBox/StatsLabel
@onready var fact_label: Label = $VBox/FactLabel

const EDUCATIONAL_FACTS := {
	"nt_synthase": "Los nucleotidos son los bloques basicos del ADN y ARN. Cada molecula contiene una base nitrogenada, un azucar (desoxirribosa) y un grupo fosfato.",
	"dna_polymerase": "La ADN Polimerasa III replica el ADN a ~1000 nucleotidos por segundo en E. coli. Es una de las enzimas mas rapidas y precisas de la biologia.",
	"rna_transcriptase": "La transcripcion ocurre en el nucleo celular. Una ARN Polimerasa lee el ADN en direccion 3'→5' y sintetiza ARNm en direccion 5'→3'.",
	"ribosome": "Un ribosoma maduro tiene dos subunidades: 60S y 40S (eucariotas). Puede sintetizar hasta 20 aminoacidos por segundo durante la traduccion.",
	"mitochondria": "Las mitocondrias tienen su propio ADN circular, evidencia de que fueron bacterias endosimbioticas. Generan ~30-32 moleculas de ATP por glucosa.",
	"sequencer": "La secuenciacion de nueva generacion (NGS) puede leer miles de millones de bases en paralelo. El Proyecto Genoma Humano tardo 13 anos; hoy se hace en horas.",
	"crispr_lab": "CRISPR-Cas9 fue descubierto en 2012 por Jennifer Doudna y Emmanuelle Charpentier, ganadoras del Nobel 2020. Puede editar cualquier gen con precision de una base.",
}


func show_producer(producer_id: String) -> void:
	var p := ResourceManager.get_producer(producer_id)
	if not p:
		return

	title = p.display_name
	title_label.text = p.display_name

	var input_str := "Ninguna (productor inicial)"
	if p.input_id != "":
		input_str = "%.1f %s por ciclo" % [p.input_per_cycle, p.input_id.to_upper()]
	process_label.text = p.description
	input_label.text = "Consume: %s" % input_str
	output_label.text = "Produce: %s (ciclo: %.1fs)" % [p.output_id.to_upper(), p.cycle_time]

	if p.level > 0:
		stats_label.text = (
			"Nivel %d | Prod/ciclo: %.3f | Bonus: x%d" % [
				p.level,
				p.get_production_per_cycle(),
				int(p._milestone_bonus())
			]
		)
	else:
		stats_label.text = "Aun no comprado"

	fact_label.text = EDUCATIONAL_FACTS.get(producer_id, "")
	popup_centered()
