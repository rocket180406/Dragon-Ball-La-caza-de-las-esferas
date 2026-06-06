extends Control

@onready var label_vidas = $LabelVidas

func _ready():
	var jugador = get_tree().get_first_node_in_group("jugadores")
	if jugador:
		jugador.vidas_actualizadas.connect(actualizar_texto_vidas)
	
	actualizar_texto_vidas(Global.vidas)

func actualizar_texto_vidas(cantidad):
	print("Mostrando vidas: ", cantidad)
	label_vidas.text = "Vidas: " + str(cantidad)
