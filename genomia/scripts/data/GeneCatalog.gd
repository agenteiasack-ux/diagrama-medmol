extends Node

# Rarity: 0=Comun, 1=Inusual, 2=Raro, 3=Epico, 4=Legendario

const GENES := {
	# ---- COMUNES (5) ----
	"herc2": {
		"id": "herc2", "name": "HERC2", "rarity": 0,
		"color": Color(0.3, 0.6, 1.0),
		"desc": "Regula el gen OCA2 determinando el color de los ojos.",
		"effect": "+5% produccion de Nt",
		"merge_into": "brca1",
		"is_mutant": false,
	},
	"abo": {
		"id": "abo", "name": "ABO", "rarity": 0,
		"color": Color(1.0, 0.4, 0.4),
		"desc": "Determina el grupo sanguineo (A, B, AB u O).",
		"effect": "-3% costo ADN Polimerasa",
		"merge_into": "tp53",
		"is_mutant": false,
	},
	"mc1r": {
		"id": "mc1r", "name": "MC1R", "rarity": 0,
		"color": Color(1.0, 0.6, 0.2),
		"desc": "Controla la produccion de melanina. Variante que causa cabello rojo.",
		"effect": "+5% produccion de ARNm",
		"merge_into": "apoe",
		"is_mutant": false,
	},
	"lct": {
		"id": "lct", "name": "LCT", "rarity": 0,
		"color": Color(0.9, 0.9, 0.3),
		"desc": "Persistencia de lactasa. Permite digerir lactosa en la edad adulta.",
		"effect": "+5% velocidad de Ribosomas",
		"merge_into": "foxp2",
		"is_mutant": false,
	},
	"abcc11": {
		"id": "abcc11", "name": "ABCC11", "rarity": 0,
		"color": Color(0.6, 0.9, 0.4),
		"desc": "Determina el tipo de cerumen seco/humedo y olor corporal.",
		"effect": "+5% produccion de ATP",
		"merge_into": "mhc",
		"is_mutant": false,
	},
	# ---- INUSUALES (5) ----
	"brca1": {
		"id": "brca1", "name": "BRCA1", "rarity": 1,
		"color": Color(0.3, 0.9, 0.3),
		"desc": "Supresor tumoral. Mutaciones aumentan riesgo de cancer de mama y ovario.",
		"effect": "Nt Sintasa x1.2",
		"merge_into": "htt",
		"is_mutant": false,
	},
	"tp53": {
		"id": "tp53", "name": "TP53", "rarity": 1,
		"color": Color(0.4, 0.8, 0.5),
		"desc": "El guardian del genoma. Mutado en mas del 50% de canceres humanos.",
		"effect": "ADN Polimerasa x1.2",
		"merge_into": "cftr",
		"is_mutant": false,
	},
	"apoe": {
		"id": "apoe", "name": "APOE", "rarity": 1,
		"color": Color(0.5, 0.7, 0.9),
		"desc": "APOE4 es el mayor factor genetico de riesgo de Alzheimer esporadico.",
		"effect": "ARN Transcriptasa x1.2",
		"merge_into": "pah",
		"is_mutant": false,
	},
	"foxp2": {
		"id": "foxp2", "name": "FOXP2", "rarity": 1,
		"color": Color(0.8, 0.5, 0.9),
		"desc": "El gen del lenguaje. Esencial para el habla y la gramatica compleja.",
		"effect": "Ribosoma x1.2",
		"merge_into": "sox2",
		"is_mutant": false,
	},
	"mhc": {
		"id": "mhc", "name": "MHC", "rarity": 1,
		"color": Color(0.9, 0.7, 0.3),
		"desc": "Complejo mayor de histocompatibilidad. Controla el reconocimiento inmune.",
		"effect": "Mitocondria x1.2",
		"merge_into": "mybpc3",
		"is_mutant": false,
	},
	# ---- RAROS (5) ----
	"htt": {
		"id": "htt", "name": "HTT", "rarity": 2,
		"color": Color(0.3, 0.5, 1.0),
		"desc": "Huntingtina. Repeticiones CAG mayores a 36 causan enfermedad de Huntington.",
		"effect": "Click power x1.5",
		"merge_into": "cas9",
		"is_mutant": false,
	},
	"cftr": {
		"id": "cftr", "name": "CFTR", "rarity": 2,
		"color": Color(0.6, 0.3, 1.0),
		"desc": "Canal de cloro. Mutaciones en ambas copias causan fibrosis quistica.",
		"effect": "Produccion global x1.3",
		"merge_into": "cas9",
		"is_mutant": false,
	},
	"pah": {
		"id": "pah", "name": "PAH", "rarity": 2,
		"color": Color(1.0, 0.4, 0.8),
		"desc": "Fenilalanina hidroxilasa. Su deficiencia causa fenilcetonuria (PKU).",
		"effect": "Secuenciador x1.5",
		"merge_into": "genome_alpha",
		"is_mutant": false,
	},
	"sox2": {
		"id": "sox2", "name": "SOX2", "rarity": 2,
		"color": Color(0.4, 0.9, 0.8),
		"desc": "Factor clave en celulas madre pluripotentes (iPSC) y desarrollo neural.",
		"effect": "Todos los productores +15%",
		"merge_into": "genome_alpha",
		"is_mutant": false,
	},
	"mybpc3": {
		"id": "mybpc3", "name": "MYBPC3", "rarity": 2,
		"color": Color(1.0, 0.5, 0.2),
		"desc": "Proteina cardiaca de union a miosina. Mutaciones causan miocardiopatia.",
		"effect": "ATP x2",
		"merge_into": "genome_beta",
		"is_mutant": false,
	},
	# ---- EPICOS (3) ----
	"cas9": {
		"id": "cas9", "name": "CAS9", "rarity": 3,
		"color": Color(0.5, 0.3, 1.0),
		"desc": "Nucleasa Cas9 de Streptococcus pyogenes. El bisturi molecular de CRISPR.",
		"effect": "CRISPR Lab x2 | Click x2",
		"merge_into": "genome_omega",
		"is_mutant": false,
	},
	"genome_alpha": {
		"id": "genome_alpha", "name": "Genoma-Alpha", "rarity": 3,
		"color": Color(0.7, 0.2, 1.0),
		"desc": "Configuracion genomica de primera generacion con maxima eficiencia.",
		"effect": "Produccion global x2",
		"merge_into": "genome_omega",
		"is_mutant": false,
	},
	"genome_beta": {
		"id": "genome_beta", "name": "Genoma-Beta", "rarity": 3,
		"color": Color(1.0, 0.3, 0.7),
		"desc": "Configuracion genomica de segunda generacion con mejoras energeticas.",
		"effect": "ATP y proteinas x2",
		"merge_into": "genome_omega",
		"is_mutant": false,
	},
	# ---- LEGENDARIOS (2) ----
	"genome_omega": {
		"id": "genome_omega", "name": "OMEGA", "rarity": 4,
		"color": Color(1.0, 0.85, 0.0),
		"desc": "El genoma perfeccionado. Culminacion de millones de anos de evolucion dirigida.",
		"effect": "Todo x3 | Habilita Evolucion",
		"merge_into": "",
		"is_mutant": true,
	},
	"crispr_mutant": {
		"id": "crispr_mutant", "name": "Mutante CRISPR", "rarity": 4,
		"color": Color(0.0, 1.0, 0.6),
		"desc": "Organismo editado con precision de base unica. Capacidades sin precedentes.",
		"effect": "CRISPR Lab x5 | Genes x2",
		"merge_into": "",
		"is_mutant": true,
	},
}

const RARITY_COLORS := {
	0: Color(0.65, 0.65, 0.65),
	1: Color(0.3, 0.82, 0.3),
	2: Color(0.3, 0.55, 1.0),
	3: Color(0.72, 0.3, 1.0),
	4: Color(1.0, 0.78, 0.0),
}

const RARITY_NAMES := {
	0: "Comun",
	1: "Inusual",
	2: "Raro",
	3: "Epico",
	4: "Legendario",
}

const COMMON_IDS := ["herc2", "abo", "mc1r", "lct", "abcc11"]


func get_gene(id: String) -> Dictionary:
	return GENES.get(id, {})


func get_random_common() -> String:
	return COMMON_IDS[randi() % COMMON_IDS.size()]


func get_rarity_color(rarity: int) -> Color:
	return RARITY_COLORS.get(rarity, Color.WHITE)


func get_rarity_name(rarity: int) -> String:
	return RARITY_NAMES.get(rarity, "")
