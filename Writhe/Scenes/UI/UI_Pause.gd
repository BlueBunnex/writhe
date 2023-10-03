extends Control

@export var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	game_manager.connect("toggle_game_paused", _ongame_manager_toggle_game_paused)

	
func _ongame_manager_toggle_game_paused(is_paused : bool):
	if (is_paused):
		show()
	else:
		hide()


func _on_button_resume_pressed():
	game_manager.game_paused = false


func _on_button_quit_pressed():
	get_tree().quit()
