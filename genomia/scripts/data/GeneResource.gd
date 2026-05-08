class_name GeneResource
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var gene_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var rarity: Rarity = Rarity.COMMON
@export var effect_type: String = ""
@export var effect_value: float = 0.0
@export var color: Color = Color.WHITE
@export var merge_result_id: String = ""
@export var is_mutant: bool = false


static func rarity_name(r: Rarity) -> String:
	match r:
		Rarity.COMMON: return "Comun"
		Rarity.UNCOMMON: return "Inusual"
		Rarity.RARE: return "Raro"
		Rarity.EPIC: return "Epico"
		Rarity.LEGENDARY: return "Legendario"
	return ""


static func rarity_color(r: Rarity) -> Color:
	match r:
		Rarity.COMMON: return Color(0.7, 0.7, 0.7)
		Rarity.UNCOMMON: return Color(0.3, 0.8, 0.3)
		Rarity.RARE: return Color(0.3, 0.5, 1.0)
		Rarity.EPIC: return Color(0.7, 0.3, 1.0)
		Rarity.LEGENDARY: return Color(1.0, 0.7, 0.0)
	return Color.WHITE
