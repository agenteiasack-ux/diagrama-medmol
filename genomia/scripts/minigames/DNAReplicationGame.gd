extends BaseMinigame

const BASES := ["A", "T", "G", "C"]
const COMPLEMENTS := {"A": "T", "T": "A", "G": "C", "C": "G"}
const SEQ_LENGTH := 12

@onready var timer_label: Label = $MainLayout/Header/TimerLabel
@onready var step_label: Label = $MainLayout/StepLabel
@onready var base_display: Label = $MainLayout/CurrentBase
@onready var score_label: Label = $MainLayout/ScoreLabel
@onready var result_panel: Control = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBox/ResultLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OKButton

var _sequence: Array = []
var _index: int = 0
var _score: int = 0


func _ready() -> void:
	$MainLayout/Header/CancelButton.pressed.connect(cancel)
	ok_btn.pressed.connect(_on_ok_pressed)
	for base in BASES:
		$MainLayout/BaseButtons.get_node(base + "Btn").pressed.connect(
			_on_base_pressed.bind(base)
		)
	result_panel.visible = false
	initialize("dna_replication", 30.0)


func _on_start() -> void:
	_sequence.clear()
	for _i in SEQ_LENGTH:
		_sequence.append(BASES[randi() % BASES.size()])
	_index = 0
	_score = 0
	result_panel.visible = false
	_refresh()


func _on_tick(_delta: float) -> void:
	pass


func _update_timer_display(remaining: float) -> void:
	timer_label.text = "%.1fs" % maxf(remaining, 0.0)


func _on_base_pressed(base: String) -> void:
	if not _active or _index >= _sequence.size():
		return
	if base == COMPLEMENTS[_sequence[_index]]:
		_score += 1
		_index += 1
		if _index >= SEQ_LENGTH:
			_active = false
			_show_result()
			return
	_refresh()


func _refresh() -> void:
	if _index < _sequence.size():
		base_display.text = _sequence[_index]
	step_label.text = "Base %d/%d" % [_index + 1, SEQ_LENGTH]
	score_label.text = "Correctas: %d" % _score


func _on_time_up() -> void:
	_show_result()


func _show_result() -> void:
	_active = false
	result_panel.visible = true
	var reward := float(_score) * 50.0
	result_label.text = (
		"Secuencia completada!\n%d/%d correctas\n+%.0f ADN" % [_score, SEQ_LENGTH, reward]
	)


func _on_ok_pressed() -> void:
	finish({"adn": float(_score) * 50.0})
