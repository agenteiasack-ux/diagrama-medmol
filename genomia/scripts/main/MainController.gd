extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var offline_popup: AcceptDialog = $OfflinePopup


func _ready() -> void:
	EventBus.load_completed.connect(_on_load_completed)
	_setup_tab_titles()


func _setup_tab_titles() -> void:
	tab_container.set_tab_title(0, "Lab")
	tab_container.set_tab_title(1, "Genoma")
	tab_container.set_tab_title(2, "Minijuegos")
	tab_container.set_tab_title(3, "Evolucion")
	tab_container.set_tab_title(4, "Logros")


func _on_load_completed(offline_sec: float) -> void:
	if offline_sec > 30.0:
		_show_offline_popup(offline_sec)


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
