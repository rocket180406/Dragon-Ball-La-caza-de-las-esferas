extends Control

@onready var etiqueta = $TextoContador

func _process(_delta):
	etiqueta.text = str(Global.bolas_recogidas) + "/7"
	
	if Global.bolas_recogidas >= 7:
		cambiar_de_nivel()

func cambiar_de_nivel():
	get_tree().change_scene_to_file("res://cinematicas/cinematica_final/cinematica_final.tscn")
