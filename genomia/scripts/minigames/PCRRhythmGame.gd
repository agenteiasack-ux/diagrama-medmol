extends BaseMinigame

const PHASES := ["Desnaturalizacion 95C", "Hibridacion 55C", "Extension 72C"]
const TOTAL_TAPS := 9

@onready var timer_label: Label = $MainLayout/Header/TimerLabel
@onready var phase_label: Label = $MainLayout/PhaseLabel
@onready var cycle_label: Label = $MainLayout/CycleLabel
@onready var bar_container: Control = $MainLayout/BarContainer
@onready var bar_fill: ColorRect = $MainLayout/BarContainer/BarFill
@onready var green_zone: ColorRect = $MainLayout/BarContainer/GreenZone
@onready var tap_btn: Button = $MainLayout/TapButton
@onready var feedback_label: Label = $MainLayout/FeedbackLabel
@onready var score_label: Label = $MainLayout/ScoreLabel
@onready var result_panel: Control = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBox/ResultLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OKButton

var _bar_pos: float = 0.0
var _bar_dir: float = 1.0
var _bar_speed: float = 0.55
var _green_start: float = 0.35
var _green_end: float = 0.65
var _tap_count: int = 0
var _score: int = 0


func _ready() -> void:
	$MainLayout/Header/CancelButton.pressed.connect(cancel)
	tap_btn.pressed.connect(_on_tap)
	ok_btn.pressed.connect(_on_ok_pressed)
	result_panel.visible = false
	initialize("pcr_rhythm", 45.0)


func _on_start() -> void:
	_bar_pos = 0.0
	_bar_dir = 1.0
	_tap_count = 0
	_score = 0
	result_panel.visible = false
	_randomize_zone()
	_refresh_labels()


func _on_tick(delta: float) -> void:
	_bar_pos += _bar_dir * _bar_speed * delta
	if _bar_pos >= 1.0:
		_bar_pos = 1.0
		_bar_dir = -1.0
	elif _bar_pos <= 0.0:
		_bar_pos = 0.0
		_bar_dir = 1.0
	_update_bar()


func _update_timer_display(remaining: float) -> void:
	timer_label.text = "%.1fs" % maxf(remaining, 0.0)


func _update_bar() -> void:
	var w := bar_container.size.x
	if w <= 0.0:
		return
	bar_fill.position.x = _bar_pos * w - bar_fill.size.x * 0.5
	green_zone.position.x = _green_start * w
	green_zone.size.x = (_green_end - _green_start) * w


func _on_tap() -> void:
	if not _active:
		return
	var in_zone := _bar_pos >= _green_start and _bar_pos <= _green_end
	if in_zone:
		_score += 1
		feedback_label.text = "PERFECTO!"
		feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		feedback_label.text = "Fuera del rango"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
	_tap_count += 1
	_randomize_zone()
	_refresh_labels()
	if _tap_count >= TOTAL_TAPS:
		_active = false
		_show_result()


func _randomize_zone() -> void:
	var size := 0.22 + randf() * 0.18
	_green_start = randf() * (1.0 - size)
	_green_end = _green_start + size


func _refresh_labels() -> void:
	phase_label.text = PHASES[_tap_count % 3]
	cycle_label.text = "Ciclo %d/3 — Paso %d/3" % [_tap_count / 3 + 1, _tap_count % 3 + 1]
	score_label.text = "Perfectos: %d/%d" % [_score, _tap_count]


func _on_time_up() -> void:
	_show_result()


func _show_result() -> void:
	_active = false
	result_panel.visible = true
	var reward := float(_score) * 30.0
	result_label.text = (
		"PCR terminado!\n%d/%d perfectos\n+%.0f ARNm" % [_score, TOTAL_TAPS, reward]
	)


func _on_ok_pressed() -> void:
	finish({"mrna": float(_score) * 30.0})
