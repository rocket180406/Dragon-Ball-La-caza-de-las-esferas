extends CharacterBody2D

# Movimiento patrulla
@export var speed: float = 60.0
@export var rango_patruya: float = 100.0

@export var speed_perseguir: float = 45.0
@export var distancia_deteccion: float = 120.0

@export var vidas: int = 2
@export var fuerza_repulsion: float = 350.0
var esta_repelido: bool = false

var posicion_inicial: Vector2
var sentido := 1
var jugador = null

func _ready() -> void:
	posicion_inicial = global_position
	$ani_ene_dyn.play("default")

func _physics_process(delta: float) -> void:

	if esta_repelido:
		move_and_slide()
		return

	buscar_jugador()

	if jugador != null:
		var objetivo = jugador.global_position + Vector2(0, -20)
		var direccion = (objetivo - global_position).normalized()

		velocity = direccion * speed_perseguir

		if is_on_wall():
			velocity.y = -40

		# Flip sprite
		if velocity.x > 0:
			$ani_ene_dyn.flip_h = false
		elif velocity.x < 0:
			$ani_ene_dyn.flip_h = true
			
	else:
		velocity.y = sin(Time.get_ticks_msec() * 0.003) * 10
		velocity.x = speed * sentido
		
		if global_position.x > posicion_inicial.x + rango_patruya:
			sentido = -1

		if global_position.x < posicion_inicial.x - rango_patruya:
			sentido = 1

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

func recibir_dano(posicion_origen: Vector2, fuerza_recibida: float = 350.0):
	vidas -= 1
	
	if vidas <= 0:
		queue_free()
		return

	var origen = posicion_origen
	
	if origen == Vector2.ZERO:
		var lista_jugadores = get_tree().get_nodes_in_group("jugadores")
		if lista_jugadores.size() > 0:
			origen = lista_jugadores[0].global_position
			
	var direccion_empuje = (global_position - origen).normalized()
	
	velocity = direccion_empuje * fuerza_recibida
	
	esta_repelido = true
	await get_tree().create_timer(0.2).timeout
	esta_repelido = false
