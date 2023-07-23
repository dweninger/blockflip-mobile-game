extends Node2D

class_name Pipe

signal player_entered
signal point_scored

var speed = 0
@onready var pipe_sprite = $Pipe/Sprite2D
	
func _process(delta):
	position.x += speed + delta
	
func set_speed(new_speed):
	speed = new_speed
	
func _on_body_entered(body):
	player_entered.emit()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	point_scored.emit()
	
func change_obsticle_sprite(path):
	var loaded_sprite = load(path)
	if loaded_sprite == pipe_sprite.texture:
		return
	pipe_sprite.texture = loaded_sprite
