extends Node

class_name Fade

@onready var animation_player = $AnimationPlayer

func play():
	animation_player.play("fade")
