extends BaseMinigame

const BASES := ["A", "T", "G", "C"]
const SEQ_LEN := 4
const MAX_TRIES := 5

@onready var timer_label: Label = $MainLayout/Header/TimerLabel
@onready var guess_grid: GridContainer = $MainLayout/GuessGrid
@onready var slot0: Label = $MainLayout/CurrentGuess/Display/Slot0
@onready var slot1: Label = $MainLayout/CurrentGuess/Display/Slot1
@onready var slot2: Label = $MainLayout/CurrentGuess/Display/Slot2
@onready var slot3: Label = $MainLayout/CurrentGuess/Display/Slot3
@onready var result_panel: Control = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBox/ResultLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OKButton

var _secret: Array = []
var _guess: Array = []
var _try_count: int = 0
var _won: bool = false
var _slots: Array = []


func _ready() -> void:
	$MainLayout/Header/CancelButton.pressed.connect(cancel)
	ok_btn.pressed.connect(_on_ok_pressed)
	for base in BASES:
		$MainLayout/CurrentGuess/Buttons.get_node(base + "Btn").pressed.connect(
			_on_base_pressed.bind(base)
		)
	$MainLayout/CurrentGuess/Buttons/DelBtn.pressed.connect(_on_delete)
	$MainLayout/CurrentGuess/Buttons/OKBtn.pressed.connect(_on_submit)
	result_panel.visible = false
	initialize("gatk_sequencing", 60.0)


func _on_start() -> void:
	_secret.clear()
	_guess.clear()
	_try_count = 0
	_won = false
	result_panel.visible = false
	for _i in SEQ_LEN:
		_secret.append(BASES[randi() % BASES.size()])
	_slots = [slot0, slot1, slot2, slot3]
	_build_grid()
	_refresh_slots()


func _build_grid() -> void:
	for child in guess_grid.get_children():
		child.queue_free()
	for _row in MAX_TRIES:
		for _col in SEQ_LEN:
			var lbl := Label.new()
			lbl.custom_minimum_size = Vector2(72, 60)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.text = "?"
			lbl.add_theme_font_size_override("font_size", 20)
			lbl.add_theme_color_override("font_color", Color(0.25, 0.25, 0.35))
			guess_grid.add_child(lbl)


func _on_base_pressed(base: String) -> void:
	if not _active or _guess.size() >= SEQ_LEN:
		return
	_guess.append(base)
	_refresh_slots()


func _on_delete() -> void:
	if not _active or _guess.is_empty():
		return
	_guess.pop_back()
	_refresh_slots()


func _on_submit() -> void:
	if not _active or _guess.size() < SEQ_LEN:
		return
	_evaluate()


func _refresh_slots() -> void:
	for i in SEQ_LEN:
		_slots[i].text = _guess[i] if i < _guess.size() else "_"


func _evaluate() -> void:
	var row_offset := _try_count * SEQ_LEN
	var children := guess_grid.get_children()
	var secret_copy := _secret.duplicate()
	var result := []
	result.resize(SEQ_LEN)

	for i in SEQ_LEN:
		if _guess[i] == _secret[i]:
			result[i] = 2  # exact
			secret_copy[i] = ""
		else:
			result[i] = 0

	for i in SEQ_LEN:
		if result[i] == 0:
			var idx := secret_copy.find(_guess[i])
			if idx != -1:
				result[i] = 1  # wrong position
				secret_copy[idx] = ""

	var color_map := [Color(0.3, 0.3, 0.4), Color(0.9, 0.75, 0.1), Color(0.2, 0.9, 0.3)]
	for i in SEQ_LEN:
		var lbl: Label = children[row_offset + i]
		lbl.text = _guess[i]
		lbl.add_theme_color_override("font_color", color_map[result[i]])

	_try_count += 1
	_won = result.all(func(r): return r == 2)
	_guess.clear()
	_refresh_slots()

	if _won or _try_count >= MAX_TRIES:
		_active = false
		_show_result()


func _update_timer_display(remaining: float) -> void:
	timer_label.text = "%.1fs" % maxf(remaining, 0.0)


func _on_time_up() -> void:
	_show_result()


func _show_result() -> void:
	_active = false
	result_panel.visible = true
	if _won:
		var bonus := float(MAX_TRIES - _try_count + 1) * 5.0 + 10.0
		result_label.text = (
			"Secuencia descifrada!\nIntentos: %d/%d\n+%.0f Genes" % [_try_count, MAX_TRIES, bonus]
		)
	else:
		result_label.text = (
			"No descifrada.\nSecuencia: %s\n+1 Gene" % " ".join(_secret)
		)


func _on_ok_pressed() -> void:
	var reward := 1.0
	if _won:
		reward = float(MAX_TRIES - _try_count + 1) * 5.0 + 10.0
	finish({"genes": reward})
