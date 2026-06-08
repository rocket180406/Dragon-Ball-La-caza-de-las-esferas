extends CharacterBody2D

@export var speed: float = 60.0
@export var rango_patruya: float = 100.0

@export var speed_perseguir: float = 45.0
@export var distancia_deteccion: float = 120.0

@export var vidas: int = 2

var posicion_inicial: Vector2
var sentido := 1
var jugador = null
var esta_atacando: bool = false
var esta_repelido = false

func _ready() -> void:
	posicion_inicial = global_position
	$ani_ene_dyn.play("default")

func _physics_process(delta: float) -> void:
	if esta_atacando:
		return
	

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
		ejecutar_animacion_ataque(body)

func ejecutar_animacion_ataque(objetivo_jugador: Node2D):
	esta_atacando = true
	velocity = Vector2.ZERO 
	
	var direccion_ataque = (objetivo_jugador.global_position - global_position).normalized()
	
	$ani_ene_dyn.flip_h = false
	$ani_ene_dyn.rotation = direccion_ataque.angle()
	
	if direccion_ataque.x < 0:
		$ani_ene_dyn.flip_v = true
	else:
		$ani_ene_dyn.flip_v = false
		
	$ani_ene_dyn.play("attack")


func _on_ani_ene_dyn_animation_finished() -> void:
	if $ani_ene_dyn.animation == "attack":
		esta_atacando = false
		$ani_ene_dyn.rotation = 0
		$ani_ene_dyn.flip_v = false 
		$ani_ene_dyn.play("default")
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
