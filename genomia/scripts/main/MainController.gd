extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var offline_popup: AcceptDialog = $OfflinePopup
@onready var toast_container: Control = $ToastContainer
@onready var toast_label: Label = $ToastContainer/ToastBG/ToastLabel

var _toast_timer: float = 0.0


func _ready() -> void:
	EventBus.load_completed.connect(_on_load_completed)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)
	_setup_tab_titles()


func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			toast_container.visible = false


func _setup_tab_titles() -> void:
	tab_container.set_tab_title(0, "Lab")
	tab_container.set_tab_title(1, "Genoma")
	tab_container.set_tab_title(2, "Minijuegos")
	tab_container.set_tab_title(3, "Evolucion")
	tab_container.set_tab_title(4, "Logros")


func _on_load_completed(offline_sec: float) -> void:
	if offline_sec > 30.0:
		_show_offline_popup(offline_sec)


func _on_achievement_unlocked(_id: String, title: String) -> void:
	toast_label.text = "Logro: %s" % title
	toast_container.visible = true
	_toast_timer = 3.0


func _show_offline_popup(seconds: float) -> void:
	var hours := int(seconds) / 3600
	var minutes := (int(seconds) % 3600) / 60
	var time_str: String
	if hours > 0:
		time_str = "%dh %dm" % [hours, minutes]
	else:
		time_str = "%d minutos" % minutes
	offline_popup.title = "Bienvenido de vuelta"
	offline_popup.dialog_text = (
		"Estuviste ausente %s.\nTus laboratorios siguieron trabajando!" % time_str
	)
	offline_popup.popup_centered()
