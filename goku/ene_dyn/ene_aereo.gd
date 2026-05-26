extends CharacterBody2D

# Movimiento patrulla
@export var speed: float = 60.0
@export var rango_patruya: float = 100.0

# Movimiento persecución
@export var speed_perseguir: float = 45.0
@export var distancia_deteccion: float = 120.0

# Posición inicial
var posicion_inicial: Vector2

# Dirección horizontal
var sentido := 1

# Referencia al jugador
var jugador = null

func _ready() -> void:
	posicion_inicial = global_position
	$ani_ene_dyn.play("default")

func _physics_process(delta: float) -> void:

	# Buscar jugador
	buscar_jugador()

	# =========================
	# PERSEGUIR JUGADOR
	# =========================
	if jugador != null:
		
		var direccion = (jugador.global_position - global_position).normalized()

		velocity = direccion * speed_perseguir

		# Evitar quedarse pegado a paredes
		if is_on_wall():
			velocity.y = -40

		# Flip sprite
		if velocity.x > 0:
			$ani_ene_dyn.flip_h = false
		elif velocity.x < 0:
			$ani_ene_dyn.flip_h = true

	# =========================
	# PATRULLA AÉREA
	# =========================
	else:

		velocity.y = sin(Time.get_ticks_msec() * 0.003) * 10

		velocity.x = speed * sentido

		# Cambiar dirección por rango
		if global_position.x > posicion_inicial.x + rango_patruya:
			sentido = -1

		if global_position.x < posicion_inicial.x - rango_patruya:
			sentido = 1

		# Cambiar dirección si toca pared
		if is_on_wall():
			sentido *= -1

		# Flip sprite
		if sentido == 1:
			$ani_ene_dyn.flip_h = false
		else:
			$ani_ene_dyn.flip_h = true

	move_and_slide()

func buscar_jugador():

	jugador = null

	for body in get_tree().get_nodes_in_group("jugadores"):

		var distancia = global_position.distance_to(body.global_position)

		if distancia <= distancia_deteccion:
			jugador = body
			return

func _on_ene_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("jugadores"):
		body.recibir_danio()
