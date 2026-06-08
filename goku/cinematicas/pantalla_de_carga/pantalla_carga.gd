extends Node2D

@export var next_scene: String = "res://environment/environmentBossfight.tscn"

func _ready():
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file(next_scene)
