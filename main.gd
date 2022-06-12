extends Node3D


@onready var ip_address = get_node("%IPAddress")
@onready var login = get_node("%Login")


func on_connect_to_server_pressed():
	login.hide()


func on_host_game_pressed():
	login.hide()
