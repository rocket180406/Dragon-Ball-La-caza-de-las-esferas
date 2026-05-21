extends CharacterBody2D

signal vidas_actualizadas(cantidad)
signal jugador_murio

@export var speed = 350
@export var acceleration = 250
@export var gravity_scale = 2
@export var friction = 20000
@export var jump_force = -700
@export var air_acceleration = 2000
@export var air_friction = 700

@onready var ani_player = $AnimatedSprite2D
@onready var attack = $attack
@onready var jump = $jump
@onready var dead = $dead

var atacar: bool = false
var muerto: bool = false

func _ready() -> void:
	add_to_group("jugadores")
	emit_signal("vidas_actualizadas", Global.vidas)
	Global.detener_tiempo = false
	
	var contador = get_tree().root.find_child("Timer", true, false)
	if contador:
		contador.timeout.connect(morir_definitivamente)
		
func _physics_process(delta: float) -> void:
	if muerto: return 
	
	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")
	
	apply_gravity(delta)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_jump()
	handle_air_acceleration(input_axis, delta)
	
	if Input.is_action_just_pressed("atacar") and not atacar:
		ejecutar_ataque()
	
	if not atacar:
		update_animation(input_axis)
		
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("agua"):
			recibir_danio()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += get_gravity().y * gravity_scale * delta
		
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)
		
func handle_jump():
	if is_on_floor():
		if Input.is_action_pressed("saltar"):
			velocity.y = jump_force

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)

func update_animation(input_axis):
	if not is_on_floor():
		if ani_player.animation != "jump":
			ani_player.play("jump")
			jump.play()
	elif input_axis != 0:
		ani_player.speed_scale = max(abs(velocity.x) / speed, 0.7)
		ani_player.flip_h = (input_axis < 0)
		if ani_player.animation != "run":
			ani_player.play("run")
	else:
		ani_player.speed_scale = 1
		if ani_player.animation != "idle":
			ani_player.play("idle")
			
func ejecutar_ataque():
	atacar = true
	ani_player.play("attack")
	attack.play()
	await ani_player.animation_finished
	atacar = false

func recibir_danio():
	if muerto: return
	
	Global.vidas -= 1
	emit_signal("vidas_actualizadas", Global.vidas)
	
	if Global.vidas <= 0:
		morir_definitivamente()
	else:
		reiniciar_nivel()

func reiniciar_nivel():
	muerto = true
	set_physics_process(false) 
	
	ani_player.play("dead") 
	dead.play()
	await ani_player.animation_finished
	get_tree().reload_current_scene()

func morir_definitivamente():
	muerto = true
	Global.detener_tiempo = true
	emit_signal("jugador_murio") 
	set_physics_process(false)
	
	ani_player.play("dead")
	dead.play()
	await ani_player.animation_finished	
	get_tree().change_scene_to_file("res://menu_muerte/menu_muerte.tscn")
