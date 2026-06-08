extends Area2D

@onready var recoger = $recoger

var recogido: bool = false

func _on_body_entered(body):
	if recogido == false:
		if body.is_in_group("jugadores"):
			Global.bolas_recogidas += 1
			recogido = true
			recoger.play()
			hide()
			await recoger.finished
			queue_free()
