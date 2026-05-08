extends Control

@onready var game_list: VBoxContainer = $MainLayout/ListScroll/GameList
@onready var game_area: Control = $GameArea

const GAME_SCENES := {
	"dna_replication":    "res://scenes/minigames/DNAReplication.tscn",
	"pcr_rhythm":         "res://scenes/minigames/PCRRhythm.tscn",
	"gel_electrophoresis":"res://scenes/minigames/GelElectrophoresis.tscn",
	"gatk_sequencing":    "res://scenes/minigames/GATKSequencing.tscn",
	"crispr_cut":         "res://scenes/minigames/CRISPRCut.tscn",
}

const GAME_NAMES := {
	"dna_replication":    "Replicacion ADN",
	"pcr_rhythm":         "PCR Termociclado",
	"gel_electrophoresis":"Electroforesis",
	"gatk_sequencing":    "Secuenciacion GATK",
	"crispr_cut":         "Corte CRISPR",
}

const GAME_DESC := {
	"dna_replication":    "Completa bases complementarias A-T / G-C",
	"pcr_rhythm":         "Marca el ritmo del ciclo termico",
	"gel_electrophoresis":"Ordena fragmentos de ADN por tamano",
	"gatk_sequencing":    "Descifra la secuencia de 4 bases",
	"crispr_cut":         "Corta con precision en el sitio activo",
}

const GAME_REWARDS := {
	"dna_replication":    "Recompensa: ADN",
	"pcr_rhythm":         "Recompensa: mARN",
	"gel_electrophoresis":"Recompensa: Genes",
	"gatk_sequencing":    "Recompensa: Genes especiales",
	"crispr_cut":         "Recompensa: ATP",
}

var _active_game: BaseMinigame = null
var _play_buttons: Dictionary = {}
var _refresh_timer: float = 0.0


func _ready() -> void:
	_build_list()
	EventBus.minigame_unlocked.connect(func(_id: String): _build_list())


func _process(delta: float) -> void:
	if _active_game != null:
		return
	_refresh_timer += delta
	if _refresh_timer >= 1.0:
		_refresh_timer = 0.0
		_refresh_buttons()


func _build_list() -> void:
	for child in game_list.get_children():
		child.queue_free()
	_play_buttons.clear()
	for id in MiniGameManager.UNLOCK_ORDER:
		_add_card(id)


func _add_card(game_id: String) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 130)
	game_list.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(vbox)

	var name_lbl := Label.new()
	name_lbl.text = GAME_NAMES.get(game_id, game_id)
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	vbox.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = GAME_DESC.get(game_id, "")
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	var reward_lbl := Label.new()
	reward_lbl.text = GAME_REWARDS.get(game_id, "")
	reward_lbl.add_theme_font_size_override("font_size", 13)
	reward_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	vbox.add_child(reward_lbl)

	var play_btn := Button.new()
	play_btn.custom_minimum_size = Vector2(130, 80)
	play_btn.add_theme_font_size_override("font_size", 17)
	play_btn.pressed.connect(_on_play_pressed.bind(game_id))
	hbox.add_child(play_btn)

	_play_buttons[game_id] = play_btn
	_update_button(game_id)


func _update_button(game_id: String) -> void:
	var btn: Button = _play_buttons.get(game_id)
	if not is_instance_valid(btn):
		return
	if not MiniGameManager.is_unlocked(game_id):
		btn.text = "Bloqueado"
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5)
	elif not MiniGameManager.is_available(game_id):
		btn.text = MiniGameManager.get_remaining_text(game_id)
		btn.disabled = true
		btn.modulate = Color(0.9, 0.7, 0.2)
	else:
		btn.text = "JUGAR"
		btn.disabled = false
		btn.modulate = Color(1.0, 1.0, 1.0)


func _refresh_buttons() -> void:
	for id in _play_buttons:
		_update_button(id)


func _on_play_pressed(game_id: String) -> void:
	if _active_game != null:
		return
	if not MiniGameManager.is_available(game_id):
		return
	var packed: PackedScene = load(GAME_SCENES.get(game_id, ""))
	if not packed:
		return
	_active_game = packed.instantiate() as BaseMinigame
	game_area.add_child(_active_game)
	_active_game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_active_game.game_completed.connect(_on_game_completed.bind(game_id))
	_active_game.game_canceled.connect(_on_game_canceled)
	game_area.visible = true
	EventBus.minigame_started.emit(game_id)


func _on_game_completed(rewards: Dictionary, game_id: String) -> void:
	MiniGameManager.on_completed(game_id)
	for resource_id in rewards:
		ResourceManager.add_resource(resource_id, rewards[resource_id])
	EventBus.minigame_completed.emit(game_id, rewards)
	_cleanup_game()


func _on_game_canceled() -> void:
	_cleanup_game()


func _cleanup_game() -> void:
	if is_instance_valid(_active_game):
		_active_game.queue_free()
	_active_game = null
	game_area.visible = false
	_refresh_buttons()
