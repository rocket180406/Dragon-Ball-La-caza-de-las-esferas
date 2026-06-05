extends CharacterBody2D

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@export var speed = 50

@export var vidas: int = 2
@export var fuerza_repulsion: float = 350.0
var esta_repelido: bool = false

var sentido = 1

func _ready() -> void:
	$ani_ene_dyn.play("default")

# NUEVA FUNCIÓN: Comprueba si el rayo toca tierra y no es agua
func hay_suelo_seguro(detector: RayCast2D) -> bool:
	if detector.is_colliding():
		var obstaculo = detector.get_collider()
		if obstaculo and not obstaculo.is_in_group("agua"):
			return true
	return false

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if esta_repelido:
		# Si lo empujan a la derecha pero se acaba el suelo, lo frenamos en seco
		if velocity.x > 0 and not hay_suelo_seguro($detectorDerecho):
			velocity.x = 0
		# Si lo empujan a la izquierda pero se acaba el suelo, lo frenamos en seco
		elif velocity.x < 0 and not hay_suelo_seguro($detectorIzquierdo):
			velocity.x = 0
			
		move_and_slide()
		return
		
	if is_on_floor():
		if is_on_wall():
			sentido = -sentido
			
		if sentido == 1:
			if hay_suelo_seguro($detectorDerecho):
				velocity.x = speed
				$ani_ene_dyn.flip_h = false
			else:
				sentido = -1
		else:
			if hay_suelo_seguro($detectorIzquierdo):
				velocity.x = -speed
				$ani_ene_dyn.flip_h = true
			else:
				sentido = 1

	move_and_slide()

func _on_ene_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.recibir_danio()

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
	
	# OJO AQUÍ: Hemos borrado el "direccion_empuje.y -= 0.5" 
	# Forzamos a que el empuje sea 100% horizontal para que los detectores no se despeguen del suelo
	direccion_empuje.y = 0 
	
	velocity = direccion_empuje * fuerza_recibida
	
	esta_repelido = true
	await get_tree().create_timer(0.2).timeout
	esta_repelido = false
