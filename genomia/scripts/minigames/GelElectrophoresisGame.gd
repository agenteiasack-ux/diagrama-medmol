extends BaseMinigame

@onready var timer_label: Label = $MainLayout/Header/TimerLabel
@onready var instruction_label: Label = $MainLayout/InstructionLabel
@onready var fragment_container: HBoxContainer = $MainLayout/FragmentContainer
@onready var sorted_container: HBoxContainer = $MainLayout/SortedContainer
@onready var result_panel: Control = $ResultPanel
@onready var result_label: Label = $ResultPanel/VBox/ResultLabel
@onready var ok_btn: Button = $ResultPanel/VBox/OKButton

var _sizes: Array = []
var _sorted: Array = []
var _correct_order: Array = []
var _buttons: Dictionary = {}


func _ready() -> void:
	$MainLayout/Header/CancelButton.pressed.connect(cancel)
	ok_btn.pressed.connect(_on_ok_pressed)
	result_panel.visible = false
	initialize("gel_electrophoresis", 40.0)


func _on_start() -> void:
	_sorted.clear()
	_buttons.clear()
	result_panel.visible = false

	var pool := [12, 34, 78, 156, 248, 342, 500, 820]
	pool.shuffle()
	_sizes = pool.slice(0, 5)
	_correct_order = _sizes.duplicate()
	_correct_order.sort()

	for child in fragment_container.get_children():
		child.queue_free()
	for child in sorted_container.get_children():
		child.queue_free()

	for size in _sizes:
		var btn := Button.new()
		btn.text = "%d bp" % size
		btn.custom_minimum_size = Vector2(150, 70)
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_fragment_pressed.bind(size, btn))
		fragment_container.add_child(btn)
		_buttons[size] = btn

	_update_instruction()


func _on_fragment_pressed(size: int, btn: Button) -> void:
	if not _active or btn.disabled:
		return
	_sorted.append(size)
	btn.disabled = true
	btn.modulate = Color(0.4, 0.4, 0.4)

	var lbl := Label.new()
	lbl.text = "%d bp" % size
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	var expected := _correct_order[_sorted.size() - 1]
	lbl.add_theme_color_override(
		"font_color",
		Color(0.3, 1.0, 0.4) if size == expected else Color(1.0, 0.4, 0.3)
	)
	sorted_container.add_child(lbl)

	if _sorted.size() >= _sizes.size():
		_active = false
		_show_result()
	else:
		_update_instruction()


func _update_instruction() -> void:
	var remaining := []
	for size in _sizes:
		if not _buttons[size].disabled:
			remaining.append(size)
	remaining.sort()
	if remaining.is_empty():
		return
	instruction_label.text = "Selecciona el fragmento mas pequeno: %d bp" % remaining[0]


func _update_timer_display(remaining: float) -> void:
	timer_label.text = "%.1fs" % maxf(remaining, 0.0)


func _on_time_up() -> void:
	_show_result()


func _show_result() -> void:
	_active = false
	result_panel.visible = true
	var score := 0
	for i in _sorted.size():
		if i < _correct_order.size() and _sorted[i] == _correct_order[i]:
			score += 1
	var reward := 3.0 + float(score)
	result_label.text = (
		"Electroforesis completada!\n%d/5 correctos\n+%.0f Genes" % [score, reward]
	)


func _on_ok_pressed() -> void:
	var score := 0
	for i in _sorted.size():
		if i < _correct_order.size() and _sorted[i] == _correct_order[i]:
			score += 1
	finish({"genes": 3.0 + float(score)})
