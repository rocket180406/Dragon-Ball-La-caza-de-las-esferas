extends Node2D

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("zoomout")

func _on_btn_exit_pressed():
	get_tree().quit()

func _on_btn_menu_pressed():
	get_tree().change_scene_to_file("res://menu_principal/menu.tscn")
