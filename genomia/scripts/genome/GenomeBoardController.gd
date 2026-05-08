extends Control

const GeneCardScene := preload("res://scenes/genome/GeneCard.tscn")
const COLS := 5
const ROWS := 7
const CELLS := COLS * ROWS
const GENES_PER_CARD := 5.0

@onready var grid_container: GridContainer = $MainLayout/BoardScroll/Grid
@onready var sequence_btn: Button = $MainLayout/TopBar/SequenceButton
@onready var genes_label: Label = $MainLayout/TopBar/GenesLabel
@onready var board_full_label: Label = $MainLayout/TopBar/BoardFullLabel
@onready var merge_hint: Label = $MainLayout/MergeHint
@onready var mutant_log: Label = $MainLayout/MutantLog

var _grid: Array = []   # CELLS Strings or null (gene_id)
var _cells: Array = []  # Button nodes (fixed, 35)
var _selected: int = -1


func _ready() -> void:
	GameManager.genome_board = self
	_grid.resize(CELLS)
	_grid.fill(null)
	_build_cells()
	sequence_btn.pressed.connect(_on_sequence_pressed)
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.load_completed.connect(_on_load_completed)
	_refresh_top_bar()


# --- Construccion de celdas (fija, una sola vez) ---

func _build_cells() -> void:
	for i in CELLS:
		var cell := Button.new()
		cell.custom_minimum_size = Vector2(196, 148)
		cell.text = "+"
		cell.add_theme_color_override("font_color", Color(0.25, 0.25, 0.38))
		cell.pressed.connect(_on_cell_tapped.bind(i))
		grid_container.add_child(cell)
		_cells.append(cell)


# --- Acciones del jugador ---

func _on_sequence_pressed() -> void:
	if ResourceManager.resources["genes"].to_float() < GENES_PER_CARD:
		return
	var empty := _first_empty()
	if empty == -1:
		return
	ResourceManager.resources["genes"] = ResourceManager.resources["genes"].subtract(
		BigNumber.from_float(GENES_PER_CARD)
	)
	EventBus.resource_changed.emit("genes", ResourceManager.resources["genes"])
	var gene_id := GeneCatalog.get_random_common()
	_place(gene_id, empty)
	EventBus.gene_discovered.emit(gene_id)
	merge_hint.text = ""


func _on_cell_tapped(idx: int) -> void:
	if _grid[idx] == null:
		# Celda vacia: mover gen seleccionado aqui
		if _selected != -1:
			_move(_selected, idx)
	else:
		match true:
			_ when _selected == -1:
				_select(idx)
			_ when _selected == idx:
				_deselect()
			_ when _grid[_selected] == _grid[idx]:
				# Mismo gen: intentar fusion
				_attempt_merge(_grid[idx])
			_:
				# Gen diferente: cambiar seleccion
				var old := _selected
				_selected = idx
				_refresh_cell(old)
				_refresh_cell(idx)
				_update_hint()


# --- Seleccion ---

func _select(idx: int) -> void:
	_selected = idx
	_refresh_cell(idx)
	_update_hint()


func _deselect() -> void:
	var old := _selected
	_selected = -1
	_refresh_cell(old)
	merge_hint.text = ""


func _move(from_idx: int, to_idx: int) -> void:
	_grid[to_idx] = _grid[from_idx]
	_grid[from_idx] = null
	_selected = -1
	_refresh_cell(from_idx)
	_refresh_cell(to_idx)
	merge_hint.text = ""


# --- Logica de merge ---

func _attempt_merge(gene_id: String) -> void:
	var positions := _positions_of(gene_id)
	if positions.size() < 3:
		var info := GeneCatalog.get_gene(gene_id)
		merge_hint.text = (
			"%s: tienes %d/3. Necesitas %d mas para fusionar." % [
				info.get("name", gene_id), positions.size(), 3 - positions.size()
			]
		)
		_deselect()
		return
	_execute_merge(gene_id, positions)


func _execute_merge(gene_id: String, positions: Array) -> void:
	var info := GeneCatalog.get_gene(gene_id)
	var result_id: String = info.get("merge_into", "")
	if result_id == "":
		merge_hint.text = "%s es Legendario y no puede fusionarse mas." % info.get("name", gene_id)
		_deselect()
		return

	# Eliminar las 3 primeras ocurrencias
	for i in range(3):
		_grid[positions[i]] = null
		_refresh_cell(positions[i])

	_selected = -1

	# Colocar resultado
	_place(result_id, positions[0])

	var result_info := GeneCatalog.get_gene(result_id)
	var result_name: String = result_info.get("name", result_id)
	merge_hint.text = "Fusion exitosa: %s!" % result_name

	EventBus.genes_merged.emit(result_id)

	if result_info.get("is_mutant", false):
		EventBus.mutant_created.emit(result_id)
		ResourceManager.add_resource("mutants", 1.0)
		mutant_log.text = "Mutante creado: %s" % result_name

	# Comprobar si se puede volver a fusionar
	if _positions_of(result_id).size() >= 3:
		_update_hint_for(result_id)


# --- Utilidades del grid ---

func _place(gene_id: String, idx: int) -> void:
	_grid[idx] = gene_id
	_refresh_cell(idx)
	_refresh_top_bar()
	var count := _positions_of(gene_id).size()
	if count >= 3:
		_update_hint_for(gene_id)


func _positions_of(gene_id: String) -> Array:
	var result := []
	for i in CELLS:
		if _grid[i] == gene_id:
			result.append(i)
	return result


func _first_empty() -> int:
	for i in CELLS:
		if _grid[i] == null:
			return i
	return -1


# --- Actualizacion visual ---

func _refresh_cell(idx: int) -> void:
	if idx < 0 or idx >= _cells.size():
		return
	var cell: Button = _cells[idx]
	for child in cell.get_children():
		child.queue_free()
	if _grid[idx] == null:
		cell.text = "+"
		cell.modulate = Color.WHITE
	else:
		cell.text = ""
		var card: Control = GeneCardScene.instantiate()
		cell.add_child(card)
		card.anchors_preset = 15  # PRESET_FULL_RECT
		card.setup(_grid[idx], idx == _selected)
		cell.modulate = Color(1.3, 1.3, 0.5, 1.0) if idx == _selected else Color.WHITE


func _refresh_all_cells() -> void:
	for i in CELLS:
		_refresh_cell(i)


func _refresh_top_bar() -> void:
	var genes_val: float = ResourceManager.resources["genes"].to_float()
	genes_label.text = "Genes: %s" % ResourceManager.resources["genes"].format()
	var empty := _first_empty()
	sequence_btn.disabled = genes_val < GENES_PER_CARD or empty == -1
	board_full_label.visible = empty == -1


func _update_hint() -> void:
	if _selected == -1:
		return
	_update_hint_for(_grid[_selected])


func _update_hint_for(gene_id: String) -> void:
	var count := _positions_of(gene_id).size()
	var info := GeneCatalog.get_gene(gene_id)
	var name_str: String = info.get("name", gene_id)
	if count >= 3:
		merge_hint.text = "%s: tienes %d! Toca otro para FUSIONAR." % [name_str, count]
	else:
		merge_hint.text = "%s seleccionado (%d/3 para fusionar)." % [name_str, count]


func _on_resource_changed(resource_id: String, _amount: BigNumber) -> void:
	if resource_id == "genes":
		_refresh_top_bar()


func _on_load_completed(_sec: float) -> void:
	var data := SaveManager.get_genome_data()
	if not data.is_empty():
		from_dict(data)
	else:
		_refresh_all_cells()
	_refresh_top_bar()


# --- Guardar / Cargar ---

func to_dict() -> Dictionary:
	var arr := []
	for slot in _grid:
		arr.append(slot)
	return {"grid": arr}


func from_dict(data: Dictionary) -> void:
	var arr: Array = data.get("grid", [])
	for i in min(arr.size(), CELLS):
		_grid[i] = arr[i]
	_refresh_all_cells()
