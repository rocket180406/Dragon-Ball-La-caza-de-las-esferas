extends CharacterBody2D

@export var vidas := 6
@export var velocidad := 100.0
@export var distancia_ataque := 25.0 
@export var distancia_magia := 250.0
@export var fuerza_salto := -350.0
@export var gravedad := 900.0
@export var magia_scene: PackedScene
@export var cooldown_ataque := 1.0

var jugador = null
var atacando = false
var lanzando_magia = false
var puede_saltar = true
var muerto := false
var puede_atacar := true
var posicion_inicial := Vector2.ZERO
var esta_repelido := false 

@onready var sprite = $ani_piccolo
@onready var hitbox = $Area2D
@onready var colision_ataque = $Area2D/col_ene_dyn_ataque

# Tus detectores que apuntan hacia abajo
@onready var detector_izq = $detectorIzquierdo
@onready var detector_der = $detectorDerecho

@onready var sonido_aparicion = $sonido_aparicion
@onready var sonido_ataque = $sonido_ataque
@onready var sonido_proyectil = $sonido_proyectil
@onready var sonido_muerte = $sonido_muerte

func _ready():
	posicion_inicial = global_position 
	randomize()
	# Usamos set_deferred para evitar errores en el motor de físicas de Godot
	colision_ataque.set_deferred("disabled", true)

	if sonido_aparicion: sonido_aparicion.play()

	sprite.play("aparicion")
	await sprite.animation_finished
	await get_tree().create_timer(1.5).timeout
	sprite.play("idle")

	jugador = get_tree().get_first_node_in_group("jugadores")

func hay_suelo_seguro(detector: RayCast2D) -> bool:
	if detector.is_colliding():
		var obstaculo = detector.get_collider()
		if obstaculo and not obstaculo.is_in_group("agua"):
			return true
	return false

func _physics_process(delta):

	if muerto: return
	if jugador == null: return

	if not is_on_floor():
		velocity.y += gravedad * delta

	if esta_repelido:
		if velocity.x > 0 and not hay_suelo_seguro(detector_der):
			velocity.x = 0
		elif velocity.x < 0 and not hay_suelo_seguro(detector_izq):
			velocity.x = 0
			
		move_and_slide()
		return

	if atacando or lanzando_magia:
		move_and_slide()
		return

	var distancia = global_position.distance_to(jugador.global_position)
	var direccion = sign(jugador.global_position.x - global_position.x)

	# --- LÓGICA DE MOVIMIENTO CORREGIDA ---
	var distancia_retroceso = 15.0 # Distancia mínima antes de retroceder

	if distancia < distancia_retroceso:
		velocity.x = -direccion * velocidad
	elif distancia <= distancia_ataque:
		velocity.x = 0
	else:
		velocity.x = direccion * velocidad
		
	# --- PREVENCIÓN DE CAÍDAS ---
	if is_on_floor(): 
		if velocity.x > 0 and not hay_suelo_seguro(detector_der):
			velocity.x = 0
		elif velocity.x < 0 and not hay_suelo_seguro(detector_izq):
			velocity.x = 0
	
	if direccion != 0:
		sprite.flip_h = direccion < 0
		hitbox.scale.x = direccion

	if distancia > distancia_ataque:
		if is_on_wall():
			saltar()

	# --- ANIMACIONES ---
	if not atacando and not lanzando_magia:
		if not is_on_floor():
			if sprite.animation != "salto":
				sprite.play("salto")
		else:
			if abs(velocity.x) > 1:
				if sprite.animation != "caminar":
					sprite.play("caminar")
			else:
				if sprite.animation != "idle":
					sprite.play("idle")

	# --- ATAQUES CORREGIDOS ---
	if distancia <= distancia_ataque:
		if puede_atacar:
			ataque_punetazo()
	elif distancia < distancia_magia:
		if randf() < 0.003:
			ataque_magia()

	move_and_slide()

func saltar():
	if not is_on_floor(): return
	if not puede_saltar: return

	puede_saltar = false
	sprite.play("salto")
	velocity.y = fuerza_salto

	await get_tree().create_timer(0.8).timeout
	puede_saltar = true

func ataque_punetazo():
	if atacando or muerto or not puede_atacar: return

	atacando = true
	puede_atacar = false
	velocity.x = 0

	sprite.play("puñetazo")
	if sonido_ataque: sonido_ataque.play()

	await sprite.animation_finished
	sprite.play("idle")
	atacando = false
	
	await get_tree().create_timer(cooldown_ataque).timeout
	puede_atacar = true

func ataque_magia():
	if lanzando_magia or muerto: return

	lanzando_magia = true
	velocity.x = 0

	sprite.play("magia")
	if sonido_proyectil: sonido_proyectil.play()

	await sprite.animation_finished
	crear_proyectil()

	sprite.play("idle")
	lanzando_magia = false

func crear_proyectil():
	if magia_scene == null: return
	var magia = magia_scene.instantiate()
	get_parent().add_child(magia)
	magia.global_position = global_position
	if sprite.flip_h:
		magia.direccion = -1
	else:
		magia.direccion = 1

func _on_area_2d_body_entered(body):
	if muerto: return
	if body.is_in_group("jugadores"):
		if body.has_method("recibir_danio"):
			body.recibir_danio()

func recibir_dano(posicion_ataque: Vector2, fuerza: float = 250.0):
	if muerto: return
	
	vidas -= 1
	if vidas <= 0:
		morir()
		return 

	var direccion_empuje = (global_position - posicion_ataque).normalized()
	direccion_empuje.y = 0 
	
	velocity = direccion_empuje * fuerza
	esta_repelido = true
	atacando = false 
	lanzando_magia = false
	
	# ¡LA CLAVE ESTÁ AQUÍ! Si le interrumpimos el ataque, apagamos la colisión a la fuerza.
	colision_ataque.set_deferred("disabled", true)
	
	await get_tree().create_timer(0.2).timeout
	esta_repelido = false

func morir():
	muerto = true
	velocity = Vector2.ZERO
	# Desactivamos el golpe por si muere a mitad de un ataque
	colision_ataque.set_deferred("disabled", true) 
	
	sprite.play("muerte")
	if sonido_muerte: sonido_muerte.play()
	await sprite.animation_finished
	
	get_tree().change_scene_to_file("res://cinematicas/cinematica_final/cinematica_final.tscn")
	queue_free()

func reiniciar():
	global_position = posicion_inicial
	velocity = Vector2.ZERO
	atacando = false
	lanzando_magia = false
	puede_atacar = true
	esta_repelido = false
	colision_ataque.set_deferred("disabled", true)
	sprite.play("idle")

func _on_ani_piccolo_frame_changed() -> void:
	if sprite.animation == "puñetazo":
		if sprite.frame == 2: 
			colision_ataque.set_deferred("disabled", false)

func _on_ani_piccolo_animation_finished() -> void:
	if sprite.animation == "puñetazo":
		colision_ataque.set_deferred("disabled", true)
