extends Node

signal vidas_cambiadas(nueva_cantidad)

var es_inmortal: bool = false
var vidas_maximas: int = 3
var vidas: int = 3:
	set(value):
		vidas = value
		vidas_cambiadas.emit(vidas) 

var tiempo_total: float = 420.0
var tiempo_restante: float = 420.0
var detener_tiempo: bool = false
var bolas_recogidas = 0

func resetear_juego():
	vidas = vidas_maximas
	tiempo_restante = tiempo_total
	detener_tiempo = false
