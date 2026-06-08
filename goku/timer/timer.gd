extends Control 

signal timeout
signal started

@onready var label: Label = $HBoxContainer/Label 

var is_running: bool = false

func _ready():
	var jugador = get_tree().get_first_node_in_group("jugadores")
	if jugador:
		jugador.jugador_murio.connect(stop)
		
	actualizar_interfaz()
	
	if get_tree().current_scene.scene_file_path.contains("Bossfight"):
		Global.detener_tiempo = true
		is_running = false
		visible = false
		set_process(false)
		return
	
	start()

func start():
	is_running = true
	emit_signal("started")

func stop():
	is_running = false

func _process(delta: float) -> void:
	if not is_running or Global.detener_tiempo:
		return
		
	Global.tiempo_restante -= delta
	
	if Global.tiempo_restante <= 0:
		Global.tiempo_restante = 0
		is_running = false
		timeout.emit()
		set_process(false) 
	
	actualizar_interfaz()

func actualizar_interfaz():
	if is_instance_valid(label):
		var mins = int(Global.tiempo_restante) / 60
		var secs = int(Global.tiempo_restante) % 60
		label.text = "%02d:%02d" % [mins, secs]
