extends Node

@onready var player = $"../Player" as Player
@onready var pipe_spawner = $"../PipeSpawner" as PipeSpawner
@onready var ground = $"../Ground"
@onready var ceiling = $"../Ceiling"
@onready var fade = $"../Fade" as Fade
@onready var ui = $"../UI" as UI
@onready var background1_music = $background1
@onready var background2_music = $background2
@onready var background3_music = $background3
@onready var background4_music = $background4
@onready var background5_music = $background5
@onready var gameover_music = $gameover
@onready var crash_sound = $CrashSound

var points = 0

func _ready():
	gameover_music.play()
	player.game_started.connect(on_game_started)
	player.on_ceiling.connect(pipe_spawner.set_on_ceiling)
	player.on_ground.connect(pipe_spawner.set_on_ground)
	pipe_spawner.player_crashed.connect(end_game)
	pipe_spawner.point_scored.connect(on_point_scored)
	ui.start_game.connect(on_game_started)
	ui.change_skin.connect(_on_change_player_skin)
	
func on_game_started():
	gameover_music.stop()
	background1_music.play()
	pipe_spawner.start_spawning_pipes()
	ui.show()
	player.is_started = true
	SaveLoad.last_score = points
	SaveLoad.save_score()

func end_game():
	crash_sound.play()
	background1_music.stop()
	background2_music.stop()
	background3_music.stop()
	background4_music.stop()
	background5_music.stop()
	ground.stop()
	ceiling.stop()
	player.stop()
	pipe_spawner.stop()
	ui.on_game_over()
	fade.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().reload_current_scene()
	
func on_point_scored():
	points += 1
	ui.update_points(points)
	update_background_music()
	if points > SaveLoad.highest_record:
		SaveLoad.highest_record = points
		SaveLoad.save_score()
		ui.update_high_score()
	SaveLoad.last_score = points
	SaveLoad.save_score()
	
func update_background_music():
	if points == 20:
		player.up_speed()
		pipe_spawner.increase_level()
		background1_music.stop()
		background2_music.play()
	elif points == 40:
		player.up_speed()
		pipe_spawner.increase_level()
		background2_music.stop()
		background3_music.play()
	elif points == 75:
		player.up_speed()
		pipe_spawner.increase_level()
		background3_music.stop()
		background4_music.play()
	elif points == 100:
		player.up_speed()
		pipe_spawner.increase_level()
		background4_music.stop()
		background5_music.play()

func _on_change_player_skin(skin_source):
	player.change_skin(ui.selected_skin)
