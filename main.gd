extends Node3D


@onready var ip_address = get_node("%IPAddress")
@onready var login = get_node("%Login")


func on_connect_to_server_pressed():
	var client = preload("res://client/client.tscn").instantiate()
	client.connect_to_url(ip_address.text)
	add_child(client)

	login.hide()


func on_host_game_pressed():
	add_child(preload("res://server/server.tscn").instantiate())
	login.hide()
