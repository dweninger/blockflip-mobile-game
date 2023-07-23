extends CharacterBody2D

class_name Player

signal game_started

var speed = 800.0
var direction = 1
var canMove = true
var is_started = false
signal on_ground
signal on_ceiling

@onready var swoosh_sound = $swoosh
@onready var game_manager = $"../GameManager"
@onready var sprite = $Sprite2D

func _ready():
	velocity.y = speed

func _process(delta):
	if Input.is_action_just_pressed("switch"):
		direction *= -1
		velocity.y = speed * direction
		canMove = true
		swoosh_sound.play()
		
	if !is_started:
		return
	# Move the player if canMove is true
	if canMove:
		position += velocity * delta
		
func up_speed():
	speed += 30
		
func stopGround():
	canMove = false
	direction = 1
	on_ground.emit()
	
func stopCeiling():
	canMove = false
	direction = -1
	on_ceiling.emit()

func stop():
	canMove = false
	speed = 0
	velocity = Vector2.ZERO
	
func change_skin(source):
	print(source)
	var selected_texture = load(source)
	sprite.texture = selected_texture
