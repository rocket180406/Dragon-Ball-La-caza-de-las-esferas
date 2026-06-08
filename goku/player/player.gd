extends CharacterBody2D

signal vidas_actualizadas(cantidad)
signal jugador_murio

@export var speed: float = 350.0
@export var acceleration: float = 4000.0
@export var gravity_scale: float = 2.0
@export var friction: float = 6000.0
@export var jump_force: float = -700.0
@export var air_acceleration: float = 2500.0
@export var air_friction: float = 800.0

@export var cooldown_ataque: float = 0.5
@export var reverse_snap_speed: float = 50.0

@onready var ani_player = $AnimatedSprite2D
@onready var attack = $attack
@onready var jump = $jump
@onready var dead = $dead

var atacar: bool = false
var puede_atacar: bool = true
var muerto: bool = false
var cambiando_escena: bool = false
var haciendo_emote: bool = false

var punto_de_spawn: Vector2 = Vector2.ZERO

func _ready() -> void:
	punto_de_spawn = global_position
	emit_signal("vidas_actualizadas", Global.vidas)

	Global.detener_tiempo = false
	cambiando_escena = false

	var contador = get_tree().root.find_child("Timer", true, false)
	if contador:
		contador.timeout.connect(ir_a_zona_de_batalla)

func _physics_process(delta: float) -> void:
	if muerto:
		return

	if Input.is_action_just_pressed("emote") and not atacar and not haciendo_emote:
		ejecutar_emote()
		return

	if haciendo_emote:
		return

	var input_axis := Input.get_axis("mover_izquierda", "mover_derecha")

	apply_gravity(delta)
	handle_jump()
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)

	if Input.is_action_just_pressed("atacar") and not atacar and puede_atacar:
		ejecutar_ataque()

	if not atacar:
		update_animation(input_axis)

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)

		if collision.get_collider().is_in_group("agua"):
			recibir_danio()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * gravity_scale * delta

func handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = jump_force

func handle_acceleration(input_axis: float, delta: float) -> void:
	if not is_on_floor():
		return

	if input_axis == 0:
		return

	if velocity.x != 0 and sign(velocity.x) != sign(input_axis):
		if abs(velocity.x) > reverse_snap_speed:
			velocity.x = 0.0

	velocity.x = move_toward(
		velocity.x,
		speed * input_axis,
		acceleration * delta
	)

func handle_air_acceleration(input_axis: float, delta: float) -> void:
	if is_on_floor():
		return

	if input_axis != 0:
		velocity.x = move_toward(
			velocity.x,
			speed * input_axis,
			air_acceleration * delta
		)

func apply_friction(input_axis: float, delta: float) -> void:
	if input_axis != 0:
		return

	if is_on_floor():
		velocity.x = move_toward(
			velocity.x,
			0.0,
			friction * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			air_friction * delta
		)

func update_animation(input_axis: float) -> void:
	if input_axis != 0:
		ani_player.flip_h = input_axis < 0

		if input_axis < 0:
			$AreaAtaque.scale.x = -1
		else:
			$AreaAtaque.scale.x = 1

	if not is_on_floor():
		if ani_player.animation != "jump":
			ani_player.play("jump")
			jump.play()

	elif input_axis != 0:
		ani_player.speed_scale = max(abs(velocity.x) / speed, 0.7)

		if ani_player.animation != "run":
			ani_player.play("run")

	else:
		ani_player.speed_scale = 1.0

		if ani_player.animation != "idle":
			ani_player.play("idle")

func ejecutar_ataque() -> void:
	atacar = true
	puede_atacar = false

	ani_player.play("attack")
	attack.play()

	get_tree().create_timer(cooldown_ataque).timeout.connect(
		func():
			puede_atacar = true
	)

	await ani_player.animation_finished

	atacar = false

func ejecutar_emote() -> void:
	haciendo_emote = true
	velocity = Vector2.ZERO

	ani_player.play("emote")

	await ani_player.animation_finished

	haciendo_emote = false

func curar_y_guardar_spawn(nueva_posicion: Vector2) -> void:
	Global.vidas = 3
	emit_signal("vidas_actualizadas", Global.vidas)
	punto_de_spawn = nueva_posicion

func recibir_danio() -> void:
	if muerto or cambiando_escena:
		return

	if Global.es_inmortal:
		return

	Global.vidas -= 1
	emit_signal("vidas_actualizadas", Global.vidas)

	if Global.vidas <= 0:
		morir_definitivamente()
	else:
		reiniciar_nivel()

func reiniciar_nivel() -> void:
	muerto = true
	set_physics_process(false)

	ani_player.play("dead")
	dead.play()

	await ani_player.animation_finished

	global_position = punto_de_spawn

	get_tree().call_group("enemigos", "reiniciar")

	velocity = Vector2.ZERO
	muerto = false

	set_physics_process(true)
	ani_player.play("idle")

func morir_definitivamente() -> void:
	muerto = true

	Global.detener_tiempo = true
	Global.bolas_recogidas = 0
	Global.es_inmortal = false

	emit_signal("jugador_murio")

	set_physics_process(false)

	ani_player.play("dead")
	dead.play()

	await ani_player.animation_finished

	get_tree().change_scene_to_file(
		"res://menu_muerte/menu_muerte.tscn"
	)

func _on_animated_sprite_2d_frame_changed() -> void:
	if ani_player.animation == "attack":
		if ani_player.frame == 1:
			$AreaAtaque/coll_ataque.disabled = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if ani_player.animation == "attack":
		$AreaAtaque/coll_ataque.disabled = true

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(global_position, 100.0)

func ir_a_zona_de_batalla() -> void:
	if cambiando_escena:
		return

	cambiando_escena = true
	velocity = Vector2.ZERO

	get_tree().change_scene_to_file(
		"res://environment/environmentBossfight.tscn"
	)
