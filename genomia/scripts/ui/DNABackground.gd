extends Control

# Animated double-helix DNA background — very subtle, non-interactive.
# Draws sinusoidal base pairs that slowly scroll downward.

const PAIR_SPACING  := 44.0    # Vertical px between base pairs
const AMPLITUDE     := 52.0    # Horizontal swing (half-width of helix)
const DOT_RADIUS    := 3.5
const SCROLL_SPEED  := 18.0    # px / second downward
const ALPHA         := 0.07    # Opacity — intentionally faint

const _NUC_COLORS := [
	Color(0.0,  0.85, 1.0,  ALPHA),   # A — cyan
	Color(1.0,  0.45, 0.28, ALPHA),   # T — orange-red
	Color(0.25, 1.0,  0.45, ALPHA),   # G — green
	Color(0.78, 0.28, 1.0,  ALPHA),   # C — purple
]
const _PAIR_LINE_COLOR := Color(0.30, 0.32, 0.55, ALPHA * 0.6)

var _offset: float = 0.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	_offset = fmod(_offset + delta * SCROLL_SPEED, PAIR_SPACING)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	var cx := w * 0.5
	var num_pairs := int(h / PAIR_SPACING) + 3

	for i in num_pairs:
		var y := i * PAIR_SPACING - _offset
		var phase := i * 0.72    # spatial phase for helix shape
		var x1 := cx + cos(phase) * AMPLITUDE
		var x2 := cx + cos(phase + PI) * AMPLITUDE
		var col := _NUC_COLORS[i % 4]

		draw_line(Vector2(x1, y), Vector2(x2, y), _PAIR_LINE_COLOR, 1.0)
		draw_circle(Vector2(x1, y), DOT_RADIUS, col)
		draw_circle(Vector2(x2, y), DOT_RADIUS, col)

		# Extra backbone: small dot between adjacent pairs
		if i < num_pairs - 1:
			var y_next := (i + 1) * PAIR_SPACING - _offset
			var phase_next := (i + 1) * 0.72
			var x1n := cx + cos(phase_next) * AMPLITUDE
			var x2n := cx + cos(phase_next + PI) * AMPLITUDE
			var mid_col := Color(col.r, col.g, col.b, ALPHA * 0.35)
			draw_line(Vector2(x1, y), Vector2(x1n, y_next), mid_col, 1.0)
			draw_line(Vector2(x2, y), Vector2(x2n, y_next), mid_col, 1.0)
