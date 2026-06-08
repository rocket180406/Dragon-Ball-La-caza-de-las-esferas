extends Control

func _on_btn_start_pressed():
	get_tree().change_scene_to_file("res://cinematicas/cinematica_intro/cinematica_intro.tscn")
	Global.resetear_juego()


func _on_btn_end_pressed():
	get_tree().quit()
