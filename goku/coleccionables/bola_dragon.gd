extends Area2D

@onready var recoger = $recoger

func _on_body_entered(body):
	if body.is_in_group("jugadores"):
		Global.bolas_recogidas += 1
		recoger.play()
		queue_free()
		
