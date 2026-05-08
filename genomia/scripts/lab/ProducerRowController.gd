extends PanelContainer

@onready var name_label: Label = $Margin/Row/Info/NameLabel
@onready var desc_label: Label = $Margin/Row/Info/DescLabel
@onready var stats_label: Label = $Margin/Row/Info/StatsLabel
@onready var cost_label: Label = $Margin/Row/Actions/CostLabel
@onready var buy_btn: Button = $Margin/Row/Actions/BuyButton
@onready var manager_btn: Button = $Margin/Row/Actions/ManagerButton

var _producer_id: String = ""
var _initialized: bool = false


func _ready() -> void:
	buy_btn.pressed.connect(_on_buy_pressed)
	manager_btn.pressed.connect(_on_manager_pressed)


func setup(producer_id: String) -> void:
	if _initialized:
		return
	_initialized = true
	_producer_id = producer_id
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.producer_upgraded.connect(_on_producer_upgraded)
	_refresh()


func _on_buy_pressed() -> void:
	ResourceManager.buy_producer(_producer_id)


func _on_manager_pressed() -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if not p or p.level <= 0:
		return
	# Manager cuesta 100x el costo actual del productor
	var manager_cost := p.get_cost().multiply_float(100.0)
	if ResourceManager.resources["nt"].greater_than_or_equal(manager_cost):
		ResourceManager.resources["nt"] = ResourceManager.resources["nt"].subtract(manager_cost)
		p.manager_unlocked = true
		EventBus.resource_changed.emit("nt", ResourceManager.resources["nt"])
		_refresh()


func _on_resource_changed(resource_id: String, _amount: BigNumber) -> void:
	if resource_id == "nt":
		_refresh_affordability()


func _on_producer_upgraded(pid: String, _level: int) -> void:
	if pid == _producer_id:
		_refresh()


func _refresh() -> void:
	var p := ResourceManager.get_producer(_producer_id)
	if not p:
		return
	name_label.text = p.display_name
	desc_label.text = p.description
	var rate_str: String
	if p.manager_unlocked:
		rate_str = "%.2f/s (auto)" % p.get_rate_per_second()
	elif p.level > 0:
		rate_str = "manual (sin manager)"
	else:
		rate_str = "sin comprar"
	stats_label.text = "Nivel %d | %s" % [p.level, rate_str]
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
	if not p:
		return
	buy_btn.disabled = not ResourceManager.can_afford_producer(_producer_id)
