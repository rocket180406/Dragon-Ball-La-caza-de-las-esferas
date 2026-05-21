extends Node2D

@onready var ani_karin = $ani_karin

func _ready() -> void:
	ani_karin.play("idle")
