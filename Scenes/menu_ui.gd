extends CanvasLayer

class_name MenuUI

signal start_game
signal skin_menu_appear

@onready var menu_ui = $MarginContainer
@onready var high_score = $MarginContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	high_score.text = "BLOCK FLIP\nHIGH SCORE: %d" % SaveLoad.highest_record
	
func update_high_score():
	high_score.text = "BLOCK FLIP\nHIGH SCORE: %d" % SaveLoad.highest_record

func _on_start_button_pressed():
	menu_ui.hide()
	start_game.emit()

func _on_skins_button_pressed():
	menu_ui.hide()
	skin_menu_appear.emit()
