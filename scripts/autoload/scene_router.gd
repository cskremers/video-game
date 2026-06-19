extends Node
## Scene transitions: menu → lobby → game → results.

const MAIN_MENU := "res://scenes/main_menu/main_menu.tscn"
const LOBBY := "res://scenes/lobby/lobby.tscn"
const GAME := "res://scenes/game/game_level.tscn"


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func go_to_lobby() -> void:
	get_tree().change_scene_to_file(LOBBY)


func go_to_game() -> void:
	get_tree().change_scene_to_file(GAME)
