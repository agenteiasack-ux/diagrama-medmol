extends PanelContainer

@onready var name_label: Label = $Margin/MainVBox/ContentRow/Info/NameRow/NameLabel
@onready var info_btn: Button = $Margin/MainVBox/ContentRow/Info/NameRow/InfoButton
@onready var desc_label: Label = $Margin/MainVBox/ContentRow/Info/DescLabel
@onready var stats_label: Label = $Margin/MainVBox/ContentRow/Info/StatsLabel
@onready var milestone_label: Label = $Margin/MainVBox/ContentRow/Info/MilestoneLabel
@onready var cost_label: Label = $Margin/MainVBox/ContentRow/Actions/CostLabel
@onready var buy_btn: Button = $Margin/MainVBox/ContentRow/Actions/BuyButton
@onready var buy_x10_btn: Button = $Margin/MainVBox/ContentRow/Actions/BuyX10Button
@onready var manager_btn: Button = $Margin/MainVBox/ContentRow/Actions/ManagerButton
@onready var cycle_bar: ProgressBar = $Margin/MainVBox/CycleBar

var _producer_id: String = ""
var _initialized: bool = false

const MILESTONES := [10, 25, 50, 100, 200, 300, 400, 500]


func _ready() -> void:
	buy_btn.pressed.connect(_on_buy_pressed)
	buy_x10_btn.pressed.connect(_on_buy_x10_pressed)
	manager_btn.pressed.connect(_on_manager_pressed)
	info_btn.pressed.connect(_on_info_pressed)
	set_process(false)


func setup(producer_id: String) -> void:
	if _initialized:
		return
	_initialized = true
	_producer_id = producer_id
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.producer_upgraded.connect(_on_producer_upgraded)
	EventBus.producer_unlocked.connect(_on_producer_unlocked)
	_refresh()


func _process(_delta: float) -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if p and p.manager_unlocked and p.level > 0:
		cycle_bar.value = (p.timer / p.cycle_time) * 100.0


func _on_info_pressed() -> void:
	var popup: AcceptDialog = load("res://scenes/ui/InfoPopup.tscn").instantiate()
	get_tree().root.add_child(popup)
	popup.show_producer(_producer_id)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)


func _on_buy_pressed() -> void:
	ResourceManager.buy_producer(_producer_id)


func _on_buy_x10_pressed() -> void:
	ResourceManager.buy_producer_bulk(_producer_id, 10)


func _on_manager_pressed() -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if not p or p.level <= 0 or p.manager_unlocked:
		return
	var manager_cost := p.get_cost().multiply_float(100.0)
	if ResourceManager.resources["nt"].greater_than_or_equal(manager_cost):
		ResourceManager.resources["nt"] = ResourceManager.resources["nt"].subtract(manager_cost)
		p.manager_unlocked = true
		EventBus.resource_changed.emit("nt", ResourceManager.resources["nt"])
		set_process(true)
		_refresh()


func _on_resource_changed(resource_id: String, _amount: BigNumber) -> void:
	if resource_id == "nt":
		_refresh_affordability()


func _on_producer_upgraded(pid: String, _level: int) -> void:
	if pid == _producer_id:
		_refresh()


func _on_producer_unlocked(pid: String) -> void:
	if pid == _producer_id:
		_refresh()


func _refresh() -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if not p:
		return
	var unlocked := ResourceManager.is_producer_unlocked(_producer_id)
	if not unlocked:
		_show_locked()
		return
	_show_unlocked(p)


func _show_locked() -> void:
	modulate = Color(0.5, 0.5, 0.5, 0.6)
	name_label.text = "??? (Bloqueado)"
	desc_label.text = "Compra el laboratorio anterior para desbloquear."
	stats_label.text = ""
	milestone_label.text = ""
	cost_label.text = ""
	buy_btn.disabled = true
	buy_x10_btn.disabled = true
	manager_btn.disabled = true
	cycle_bar.value = 0.0


func _show_unlocked(p: ResourceManager.ProducerState) -> void:
	modulate = Color.WHITE
	name_label.text = p.display_name
	desc_label.text = p.description

	var rate_str: String
	if p.manager_unlocked:
		rate_str = "%.3f/s (auto)" % p.get_rate_per_second()
		set_process(true)
	elif p.level > 0:
		rate_str = "Prod/ciclo: %.2f (manual)" % p.get_production_per_cycle()
	else:
		rate_str = "Compra para activar"
	stats_label.text = "Nivel %d | %s" % [p.level, rate_str]

	milestone_label.text = _get_milestone_text(p)
	cost_label.text = "%s nt" % p.get_cost().format()

	if p.manager_unlocked:
		manager_btn.text = "Manager activo"
		manager_btn.disabled = true
	else:
		var mcost := p.get_cost().multiply_float(100.0)
		manager_btn.text = "Manager\n%s nt" % mcost.format()
		manager_btn.disabled = p.level <= 0

	_refresh_affordability()


func _refresh_affordability() -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if not p or not ResourceManager.is_producer_unlocked(_producer_id):
		return
	var can_buy := ResourceManager.can_afford_producer(_producer_id)
	buy_btn.disabled = not can_buy
	var cost_x10 := ResourceManager.get_producer_cost_x10(_producer_id)
	buy_x10_btn.disabled = not ResourceManager.resources["nt"].greater_than_or_equal(cost_x10)


func _get_milestone_text(p: ResourceManager.ProducerState) -> String:
	var bonus := 1.0
	var next_milestone := -1
	for m in MILESTONES:
		if p.level >= m:
			bonus *= 2.0
		elif next_milestone == -1:
			next_milestone = m
	var s := "Bonus x%d" % int(bonus)
	if next_milestone > 0:
		return "%s | Hito: %d" % [s, next_milestone]
	return s + " (MAX)"
