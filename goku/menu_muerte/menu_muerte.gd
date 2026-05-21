extends Control

func _on_btn_restart_pressed():
	Global.resetear_juego()
	get_tree().change_scene_to_file("res://environment/environment.tscn")


func _on_btn_menu_pressed():
	Global.resetear_juego()
	get_tree().change_scene_to_file("res://menu_principal/menu.tscn")
