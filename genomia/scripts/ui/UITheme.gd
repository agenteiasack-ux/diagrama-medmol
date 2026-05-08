extends Node

var theme: Theme
var font_orbitron: FontFile
var font_mono: FontFile

# Palette
const C_BG          := Color(0.05, 0.05, 0.09, 1.0)
const C_PANEL       := Color(0.07, 0.08, 0.13, 1.0)
const C_PANEL_BORDER:= Color(0.12, 0.14, 0.26, 1.0)
const C_BTN_NORMAL  := Color(0.06, 0.10, 0.18, 1.0)
const C_BTN_BORDER  := Color(0.13, 0.22, 0.38, 1.0)
const C_BTN_HOVER   := Color(0.09, 0.16, 0.28, 1.0)
const C_ACCENT      := Color(0.0,  0.83, 1.0,  1.0)
const C_ACCENT_DIM  := Color(0.0,  0.55, 0.72, 1.0)
const C_TEXT        := Color(0.88, 0.90, 0.98, 1.0)
const C_TEXT_DIM    := Color(0.50, 0.52, 0.65, 1.0)
const C_BAR_BG      := Color(0.06, 0.06, 0.12, 1.0)
const C_BAR_FILL    := Color(0.0,  0.70, 0.88, 1.0)


func _ready() -> void:
	font_orbitron = load("res://assets/fonts/Orbitron-Regular.ttf")
	font_mono     = load("res://assets/fonts/ShareTechMono-Regular.ttf")
	theme = _build()


func _build() -> Theme:
	var t := Theme.new()

	# --- Default font (monospace tech for all base text) ---
	t.default_font = font_mono
	t.default_font_size = 14

	# --------------------------------------------------------
	# BUTTON
	# --------------------------------------------------------
	t.set_stylebox("normal",   "Button", _btn_sb(C_BTN_NORMAL, C_BTN_BORDER, 2))
	t.set_stylebox("hover",    "Button", _btn_sb(C_BTN_HOVER,  C_ACCENT,     2))
	t.set_stylebox("pressed",  "Button", _btn_sb(Color(0.04, 0.07, 0.12), C_ACCENT_DIM, 2))
	t.set_stylebox("disabled", "Button", _btn_sb(Color(0.04, 0.04, 0.08), Color(0.12, 0.12, 0.20), 1))
	t.set_stylebox("focus",    "Button", _focus_sb())
	t.set_color("font_color",          "Button", C_TEXT)
	t.set_color("font_hover_color",    "Button", C_ACCENT)
	t.set_color("font_pressed_color",  "Button", C_ACCENT_DIM)
	t.set_color("font_disabled_color", "Button", Color(0.35, 0.35, 0.45))
	t.set_font("font", "Button", font_orbitron)
	t.set_font_size("font_size", "Button", 15)

	# --------------------------------------------------------
	# PANEL CONTAINER
	# --------------------------------------------------------
	t.set_stylebox("panel", "PanelContainer", _panel_sb(C_PANEL, C_PANEL_BORDER, 1, 5))

	# --------------------------------------------------------
	# TAB CONTAINER
	# --------------------------------------------------------
	var tab_content_sb := _panel_sb(Color(0.06, 0.06, 0.10), Color(0.0, 0.0, 0.0, 0.0), 0, 0)
	t.set_stylebox("panel", "TabContainer", tab_content_sb)

	t.set_stylebox("tab_selected",   "TabContainer", _tab_sb(Color(0.09, 0.10, 0.18), C_ACCENT, 3))
	t.set_stylebox("tab_unselected", "TabContainer", _tab_sb(Color(0.05, 0.05, 0.09), Color(0.14, 0.14, 0.24), 1))
	t.set_stylebox("tab_hovered",    "TabContainer", _tab_sb(Color(0.08, 0.09, 0.16), Color(0.0, 0.60, 0.75), 2))
	t.set_color("font_selected_color",   "TabContainer", C_ACCENT)
	t.set_color("font_unselected_color", "TabContainer", Color(0.55, 0.55, 0.70))
	t.set_color("font_hovered_color",    "TabContainer", Color(0.78, 0.88, 1.0))
	t.set_font("font", "TabContainer", font_orbitron)
	t.set_font_size("font_size", "TabContainer", 18)

	# --------------------------------------------------------
	# PROGRESS BAR
	# --------------------------------------------------------
	t.set_stylebox("background", "ProgressBar", _panel_sb(C_BAR_BG, Color(0.0, 0.0, 0.0, 0.0), 0, 3))
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = C_BAR_FILL
	bar_fill.set_corner_radius_all(3)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	# --------------------------------------------------------
	# SCROLL BAR
	# --------------------------------------------------------
	var scroll_track := _panel_sb(Color(0.05, 0.05, 0.09), Color(0.0, 0.0, 0.0, 0.0), 0, 3)
	var grabber_n := _panel_sb(Color(0.16, 0.18, 0.30), Color(0.0, 0.0, 0.0, 0.0), 0, 3)
	var grabber_h := _panel_sb(Color(0.22, 0.25, 0.42), Color(0.0, 0.0, 0.0, 0.0), 0, 3)
	for dir in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll",              dir, scroll_track)
		t.set_stylebox("scroll_focus",        dir, scroll_track)
		t.set_stylebox("grabber",             dir, grabber_n)
		t.set_stylebox("grabber_highlight",   dir, grabber_h)
		t.set_stylebox("grabber_pressed",     dir, grabber_h)

	# --------------------------------------------------------
	# LABEL (default color override)
	# --------------------------------------------------------
	t.set_color("font_color", "Label", C_TEXT)

	# --------------------------------------------------------
	# ACCEPT DIALOG
	# --------------------------------------------------------
	t.set_stylebox("panel", "AcceptDialog", _panel_sb(C_PANEL, C_PANEL_BORDER, 1, 8))

	return t


# --- Style helpers ---

func _btn_sb(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(bw)
	sb.border_color = border
	sb.set_corner_radius_all(8)
	sb.content_margin_left   = 10
	sb.content_margin_right  = 10
	sb.content_margin_top    = 6
	sb.content_margin_bottom = 6
	return sb


func _focus_sb() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	sb.set_border_width_all(2)
	sb.border_color = Color(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.55)
	sb.set_corner_radius_all(8)
	sb.draw_center = false
	return sb


func _panel_sb(bg: Color, border: Color, bw: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(bw)
	sb.border_color = border
	sb.set_corner_radius_all(radius)
	return sb


func _tab_sb(bg: Color, bottom_color: Color, bottom_width: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(0)
	sb.border_width_bottom = bottom_width
	sb.border_color = bottom_color
	sb.corner_radius_top_left  = 6
	sb.corner_radius_top_right = 6
	sb.content_margin_left   = 8
	sb.content_margin_right  = 8
	sb.content_margin_top    = 8
	sb.content_margin_bottom = 8
	return sb
