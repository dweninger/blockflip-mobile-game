extends CanvasLayer

class_name SkinMenu

signal show_main_menu

@onready var skin_menu_box = $MarginContainer

func _on_back_button_pressed():
	print("SkinMenu: back button pressed")
	skin_menu_box.hide()
	show_main_menu.emit()
