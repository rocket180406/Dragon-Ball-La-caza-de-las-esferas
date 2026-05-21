extends Node2D

@onready var anim = $AnimationPlayer
@onready var skip_button = $skip_button

func _ready() -> void:
	anim.play("crawl")

func _on_skip_button_pressed():
	go_to_level()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "crawl":
		await get_tree().create_timer(1.5).timeout
		go_to_level()

func go_to_level():
	get_tree().change_scene_to_file("res://environment/environment.tscn")
