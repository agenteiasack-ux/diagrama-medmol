extends BaseMinigame

const TOTAL_CUTS := 5
const TOLERANCE := 0.13

@onready var timer_label: Label = $MainLayout/Header/TimerLabel
@onready var cuts_label: Label = $MainLayout/CutsLabel
@onready var dna_display: Control = $MainLayout/DNADisplay
@onready var strand_bar: ColorRect = $MainLayout/DNADisplay/StrandBar
@onready var cursor_mark: ColorRect = $MainLayout/DNADisplay/Cursor
@onready var cut_site: ColorRect = $MainLayout/DNADisplay/CutSite
@onready var feedback_label: Label = $MainLayout/FeedbackLabel
@onready var cut_btn: Button = $MainLayout/CutButton
@onready var result_panel: Control = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBox/ResultLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OKButton

var _cursor: float = 0.0
var _cursor_dir: float = 1.0
var _cursor_speed: float = 0.5
var _site_pos: float = 0.5
var _site_active: bool = false
var _site_timer: float = 0.0
var _site_cd: float = 1.5
var _cuts_done: int = 0
var _score: int = 0


func _ready() -> void:
	$MainLayout/Header/CancelButton.pressed.connect(cancel)
	cut_btn.pressed.connect(_on_cut)
	ok_btn.pressed.connect(_on_ok_pressed)
	result_panel.visible = false
	initialize("crispr_cut", 40.0)


func _on_start() -> void:
	_cursor = 0.0
	_cursor_dir = 1.0
	_cuts_done = 0
	_score = 0
	_site_active = false
	_site_cd = 1.5
	result_panel.visible = false
	cut_site.visible = false
	_refresh_cuts()


func _on_tick(delta: float) -> void:
	_cursor += _cursor_dir * _cursor_speed * delta
	_cursor = clampf(_cursor, 0.0, 1.0)
	if _cursor >= 1.0:
		_cursor_dir = -1.0
	elif _cursor <= 0.0:
		_cursor_dir = 1.0

	if _site_active:
		_site_timer -= delta
		if _site_timer <= 0.0:
			_site_active = false
			cut_site.visible = false
			_site_cd = 0.8 + randf() * 1.2
	else:
		_site_cd -= delta
		if _site_cd <= 0.0:
			_site_pos = 0.1 + randf() * 0.8
			_site_active = true
			_site_timer = 1.5 - float(_cuts_done) * 0.1
			cut_site.visible = true

	_update_visual()


func _update_visual() -> void:
	var w := strand_bar.size.x
	if w <= 0.0:
		return
	cursor_mark.position.x = strand_bar.position.x + _cursor * w - cursor_mark.size.x * 0.5
	if _site_active:
		cut_site.position.x = strand_bar.position.x + _site_pos * w - cut_site.size.x * 0.5
		var proximity := 1.0 - absf(_cursor - _site_pos) / TOLERANCE
		cut_site.color.a = clampf(0.3 + proximity * 0.5, 0.3, 0.9)


func _on_cut() -> void:
	if not _active:
		return
	if not _site_active:
		feedback_label.text = "No hay sitio de corte activo!"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3))
		return
	var dist := absf(_cursor - _site_pos)
	_cuts_done += 1
	if dist <= TOLERANCE:
		_score += 1
		feedback_label.text = "CORTE PRECISO! (%d/%d)" % [_score, _cuts_done]
		feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		feedback_label.text = "Impreciso (distancia: %.2f)" % dist
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	_site_active = false
	cut_site.visible = false
	_site_cd = 0.6 + randf() * 0.8
	_refresh_cuts()
	if _cuts_done >= TOTAL_CUTS:
		_active = false
		_show_result()


func _refresh_cuts() -> void:
	cuts_label.text = "Cortes: %d/%d | Precisos: %d" % [_cuts_done, TOTAL_CUTS, _score]


func _update_timer_display(remaining: float) -> void:
	timer_label.text = "%.1fs" % maxf(remaining, 0.0)


func _on_time_up() -> void:
	_show_result()


func _show_result() -> void:
	_active = false
	result_panel.visible = true
	var reward := float(_score) * 100.0
	result_label.text = (
		"CRISPR completado!\n%d/%d cortes precisos\n+%.0f ATP" % [_score, _cuts_done, reward]
	)


func _on_ok_pressed() -> void:
	finish({"atp": float(_score) * 100.0})
