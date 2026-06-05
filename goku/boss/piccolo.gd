extends CharacterBody2D

@export var velocidad := 60.0
@export var distancia_ataque := 70.0
@export var distancia_magia := 250.0
@export var fuerza_salto := -350.0
@export var gravedad := 900.0
@export var magia_scene: PackedScene

var jugador = null
var atacando = false
var lanzando_magia = false
var puede_saltar = true

@onready var sprite = $ani_piccolo
@onready var hitbox = $Area2D
@onready var detector_izq = $detectorIzquierdo
@onready var detector_der = $detectorDerecho

# SONIDOS
@onready var sonido_aparicion = $sonido_aparicion
@onready var sonido_ataque = $sonido_ataque
@onready var sonido_proyectil = $sonido_proyectil

func _ready():

	randomize()

	hitbox.monitoring = false

	# SONIDO APARICION
	if sonido_aparicion:
		sonido_aparicion.play()

	sprite.play("aparicion")

	await sprite.animation_finished
	await get_tree().create_timer(1.5).timeout
	sprite.play("idle")

	jugador = get_tree().get_first_node_in_group("jugadores")

func _physics_process(delta):

	if jugador == null:
		return

	if not is_on_floor():
		velocity.y += gravedad * delta

	if atacando or lanzando_magia:
		move_and_slide()
		return

	var distancia = global_position.distance_to(jugador.global_position)

	var direccion = sign(jugador.global_position.x - global_position.x)

	velocity.x = direccion * velocidad
	sprite.flip_h = direccion < 0

	if distancia > distancia_ataque:
		if hay_muro_delante():
			saltar()

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

	if distancia <= distancia_ataque:
		velocity.x = 0
		ataque_punetazo()

	elif distancia < distancia_magia:
		if randf() < 0.003:
			ataque_magia()

	move_and_slide()

func hay_muro_delante() -> bool:

	var detector = null

	if velocity.x > 0:
		detector = detector_der
	elif velocity.x < 0:
		detector = detector_izq
	else:
		return false

	if detector.is_colliding():
		var collider = detector.get_collider()

		if collider == jugador:
			return false

		return true

	return false

func saltar():

	if not is_on_floor():
		return

	if not puede_saltar:
		return

	puede_saltar = false

	sprite.play("salto")
	velocity.y = fuerza_salto

	await get_tree().create_timer(0.8).timeout

	puede_saltar = true

func ataque_punetazo():

	if atacando:
		return

	atacando = true
	velocity.x = 0

	sprite.play("puñetazo")

	# SONIDO ATAQUE
	if sonido_ataque:
		sonido_ataque.play()

	hitbox.monitoring = true

	await sprite.animation_finished

	hitbox.monitoring = false

	sprite.play("idle")
	atacando = false

func ataque_magia():

	if lanzando_magia:
		return

	lanzando_magia = true
	velocity.x = 0

	sprite.play("magia")

	# SONIDO MAGIA
	if sonido_proyectil:
		sonido_proyectil.play()

	await sprite.animation_finished

	crear_proyectil()

	sprite.play("idle")
	lanzando_magia = false

func crear_proyectil():

	if magia_scene == null:
		print("ERROR: magia_scene no asignada")
		return

	var magia = magia_scene.instantiate()

	get_parent().add_child(magia)

	magia.global_position = global_position

	if sprite.flip_h:
		magia.direccion = -1
	else:
		magia.direccion = 1

func _on_area_2d_body_entered(body):

	if body.is_in_group("jugadores"):

		if body.has_method("recibir_danio"):
			body.recibir_danio()
