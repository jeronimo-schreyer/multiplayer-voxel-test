extends VoxelTerrain
class_name Server


@export var ray_length = 100.0
@export var edit_radius = 2.5

@onready var tool = get_voxel_tool()
@onready var world = get_world_3d()

var WS = WebSocketServer.new()
var serializer = VoxelBlockSerializer.new()
var voxel_buffer = VoxelBuffer.new()


enum PacketType {
	BLOCK_DATA,
	VOXEL_BUFFER,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	WS.client_connected.connect(on_client_connected)
	WS.client_disconnected.connect(on_client_disconnected)
	WS.client_close_request.connect(on_client_close_request)
	WS.data_received.connect(on_received_data)

	stream = preload("res://stream/world.tres")

	listen(8000, PackedStringArray(["binary"]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if WS.is_listening():
		WS.poll()


func _exit_tree():
	WS.stop()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var params = PhysicsRayQueryParameters3D.new()
		params.from = $Camera3D.project_ray_origin(event.position)
		params.to = params.from + $Camera3D.project_ray_normal(event.position) * ray_length
		var hit = world.direct_space_state.intersect_ray(params)
		if not hit.is_empty():
			tool.do_sphere(hit.position, edit_radius)
			save_modified_blocks()


func _on_data_block_entered(info):
	var peer_id = info.get_network_peer_id()
	send_voxel_buffer_to(PacketType.BLOCK_DATA, peer_id, info.get_voxels(), info.get_position())


func _on_area_edited(origin, size):
	printt("Server::_on_area_edited", origin, size)
	var peers_in_area = get_viewer_network_peer_ids_in_area(origin, size)
	if peers_in_area.size() > 0:
		voxel_buffer.create(size.x, size.y, size.z)
		tool.copy(origin, voxel_buffer, 1 << VoxelBuffer.CHANNEL_SDF)
		for peer_id in peers_in_area:
			printt("Server::_on_area_edited - viewer near edition", peer_id)
			send_voxel_buffer_to(PacketType.VOXEL_BUFFER, peer_id, voxel_buffer, origin)


func listen(port, supported_protocols):
	printt("Server::listening", int(port), ",".join(supported_protocols))
	var res = WS.listen(int(port), supported_protocols)
	if res != OK:
		printerr("Server::listen - failed to listen to port ", int(port))
		set_process(false)


func send_voxel_buffer_to(msg_id, peer_id, buffer, block_position):
	var peer = WS.get_peer(peer_id)
	var stream_peer_buffer = StreamPeerBuffer.new()
	var _size = serializer.serialize(stream_peer_buffer, buffer, true)
	peer.put_packet(var_to_bytes([msg_id, stream_peer_buffer.data_array, block_position]))


func on_client_close_request(id, code, reason=""):
	if reason == "":
		reason = "No Reason"
	printt("Server::on_client_close_request", id, code, reason)


func on_client_connected(id, protocol, resource_name):
	printt("Server::on_client_connected", id, protocol, resource_name)
	WS.get_peer(id).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)

	var remote_player = preload("res://server/remote_player.tscn").instantiate()
	remote_player.set_name(str(id))
	remote_player.get_node("VoxelViewer").set_network_peer_id(id)
	add_child(remote_player)


func on_client_disconnected(id, clean=true):
	printt("Server::on_client_disconnected", id, str(clean))
	if has_node(str(id)):
		get_node(str(id)).queue_free()


# update voxel viewer position
func on_received_data(id):
	var packet = bytes_to_var(WS.get_peer(id).get_packet())
	get_node(str(id)).global_transform = packet
