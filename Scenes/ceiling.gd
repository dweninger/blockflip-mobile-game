extends Node2D

class_name Ceiling

signal ground_hit

@export var speed = -300

@onready var sprite1 = $Ceiling1/Sprite2D
@onready var sprite2 = $Ceiling2/Sprite2D

func _ready():
	sprite2.global_position.x = sprite1.global_position.x + sprite1.texture.get_width()

func _process(delta):
	sprite1.global_position.x += speed * delta
	sprite2.global_position.x += speed * delta
	
	# Create endless scrolling effect
	if sprite1.global_position.x < -sprite1.texture.get_width():
		sprite1.global_position.x = sprite2.global_position.x + sprite2.texture.get_width()
		
	if sprite2.global_position.x < -sprite2.texture.get_width():
		sprite2.global_position.x = sprite1.global_position.x + sprite1.texture.get_width()

func _on_body_entered(body):
	ground_hit.emit()
	(body as Player).stopCeiling()

func stop():
	speed = 0
