extends Node

class_name PipeSpawner

signal player_crashed
signal point_scored

var pipe_scene = preload("res://Scenes/pipe.tscn")
var on_ground = false
var on_ceiling = true

@export var pipe_speed = -15
var level = 1
@onready var spawn_timer = $SpawnTimer
@onready var crash_sound = $CrashSound
@onready var point_sound = $PointSound

func _ready():
	spawn_timer.start()
	
func start_spawning_pipes():
	spawn_timer.timeout.connect(spawn_pipe)
	
func spawn_pipe():
	var pipe = pipe_scene.instantiate() as Pipe
	add_child(pipe)
	
	if level == 1:
		pipe.change_obsticle_sprite("res://Assets/Sprites/obsticlegreen.png")
	elif level == 2:
		pipe.change_obsticle_sprite("res://Assets/Sprites/obsticleyellow.png")
		spawn_timer.wait_time = 1.5
	elif level == 3:
		pipe.change_obsticle_sprite("res://Assets/Sprites/obsticleOrange.png")
		spawn_timer.wait_time = 1
	elif level == 4:
		pipe.change_obsticle_sprite("res://Assets/Sprites/obsticleRed.png")
		spawn_timer.wait_time = 0.75
	else:
		pipe.change_obsticle_sprite("res://Assets/Sprites/obsticlePink.png")
		spawn_timer.wait_time = 0.5
	
	var viewport_rect = get_viewport().get_camera_2d().get_viewport_rect()
	pipe.position.x = viewport_rect.end.x
	
	# Get random pipe location
	var is_top = get_rand_bool()
	if is_top && on_ground:
		is_top = get_rand_bool()
	elif !is_top && on_ceiling:
		is_top = get_rand_bool()
	
	var half_height = viewport_rect.size.y / 2
	if is_top:
		pipe.position.y = randf_range(viewport_rect.size.y * 0.01 - half_height, viewport_rect.size.y * 0.18 - half_height)
		#pipe.position.y = viewport_rect.size.y * 0.1 - half_height
	else:
		pipe.position.y = randf_range(viewport_rect.size.y * 0.80 - half_height, viewport_rect.size.y * 1 - half_height)
		#pipe.position.y = viewport_rect.size.y * 0.8 - half_height
	
	#pipe.position.y = randf_range(viewport_rect.size.y * 0.15 - half_height, viewport_rect.size.y + 0.65 - half_height)
	
	pipe.player_entered.connect(on_player_entered)
	pipe.point_scored.connect(on_point_scored)
	pipe.set_speed(pipe_speed)
	
func on_player_entered():
	player_crashed.emit()
	stop()
	
func get_rand_bool():
	return randi() % 2 + 1 == 1
	
func on_point_scored():
	point_sound.play()
	point_scored.emit()
	
func increase_level():
	pipe_speed -= 2
	level += 1
	
func stop():
	spawn_timer.stop()
	for pipe in get_children().filter(func (child): return child is Pipe):
		(pipe as Pipe).speed = 0
		
func set_on_ground():
	on_ground = true
	on_ceiling = false
	
func set_on_ceiling():
	on_ceiling = true
	on_ground = false
