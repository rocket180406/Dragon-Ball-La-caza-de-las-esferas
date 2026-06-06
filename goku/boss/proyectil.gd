extends Area2D

@export var velocidad := 100.0

var direccion := 1
	
func _physics_process(delta):
	position.x += velocidad * direccion * delta
	
func _on_area_2d_body_entered(body):
	if body.is_in_group("jugadores"):
		if body.has_method("recibir_danio"):
			body.recibir_danio()
			queue_free()

func reiniciar():
	queue_free()
