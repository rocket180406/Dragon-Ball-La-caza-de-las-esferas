extends Area2D

@export var velocidad := 100.0

var direccion := 1
	
func _physics_process(delta):
	position.x += velocidad * direccion * delta
	
