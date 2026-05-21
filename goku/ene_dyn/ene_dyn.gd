extends CharacterBody2D

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@export var speed = 50

# Variable para indicar si vamos hacia delante (1) o atrás (-1)
var sentido = 1

func _ready() -> void:
	$ani_ene_dyn.play("default")
	
func _physics_process(delta: float) -> void:
	# Establecemos la velocidad
	velocity.y += gravity * delta
	if is_on_wall():
		sentido = -sentido
		
	## Si el detector delantero está detectando suelo y vamos en esa dirección
	if sentido ==1 && $detectorDerecho.is_colliding():
		velocity.x = speed
		$ani_ene_dyn.flip_h = false
	else:
		sentido = -1
	
	## Si el detector trasero está detectando suelo y vamos en esa dirección
	if sentido == -1 && $detectorIzquierdo.is_colliding():
		velocity.x = -speed
		$ani_ene_dyn.flip_h = true
	else:
		sentido = 1

	# Refrescamos el juego
	move_and_slide()

func _on_ene_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugadores"):
		body.recibir_danio()
