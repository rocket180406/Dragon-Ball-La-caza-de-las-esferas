extends Node2D

@onready var ani_karin = $ani_karin
@onready var texto_interaccion = $texto_karin
@onready var texto_info = $texto_info

var jugador_en_zona = null
var usado = false

func _process(_delta):
	if jugador_en_zona != null and Input.is_action_just_pressed("interactuar") and usado == false:
		jugador_en_zona.curar_y_guardar_spawn(global_position)
		usado = true
		texto_info.show()
		await get_tree().create_timer(2.0).timeout
		texto_info.hide()

func _ready() -> void:
	ani_karin.play("idle")


func _on_area_2d_karin_body_exited(body: Node2D) -> void:
		texto_interaccion.hide()
		jugador_en_zona = null


func _on_area_2d_karin_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		if usado == false:
			texto_interaccion.show()
		jugador_en_zona = body
