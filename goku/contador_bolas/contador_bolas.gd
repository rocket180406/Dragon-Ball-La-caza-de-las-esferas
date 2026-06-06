extends Control

@onready var etiqueta = $TextoContador

var ya_cambio_de_nivel: bool = false

func _process(_delta):
	etiqueta.text = str(Global.bolas_recogidas) + "/7"
	
	if Global.bolas_recogidas >= 1 and not ya_cambio_de_nivel:
		ya_cambio_de_nivel = true
		Global.es_inmortal = true
		Global.bolas_recogidas = 0 
		
		call_deferred("cambiar_de_nivel")

func cambiar_de_nivel():
	get_tree().change_scene_to_file("res://environment/environmentBossfight.tscn")
