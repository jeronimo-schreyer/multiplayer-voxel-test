extends VoxelTerrain


@export var ray_length = 100.0
@export var edit_radius = 2.5

@onready var camera = get_node("%Camera3D")
@onready var world = get_world_3d()
@onready var tool = get_voxel_tool()

var WS = WebSocketClient.new()
var serializer = VoxelBlockSerializer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	# WebSocketClient signals
	WS.connection_established.connect(on_client_connected)
	WS.connection_closed.connect(on_client_disconnected)
	WS.connection_error.connect(on_client_connection_failed)
	WS.data_received.connect(on_received_data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_connected_to_server():
		WS.poll()

		# update position when its actually connected
		if WS.get_peer(1).is_connected_to_host():
			WS.get_peer(1).put_packet(var2bytes($Player.global_transform))


func _exit_tree():
	WS.disconnect_from_host(1001, "Bye bye!")


func is_connected_to_server():
	return Array([
			WebSocketClient.CONNECTION_CONNECTING,
			WebSocketClient.CONNECTION_CONNECTED,
	]).has(WS.get_connection_status())


func connect_to_url(host, port=8000, protocols=["binary"]):
	printt("Client::connect_to_url - Connecting to host", host, port, protocols)

	if WS.connect_to_url("ws://%s:%d" % [host, port], protocols) != OK:
		set_process(false)


func deserialize_voxel_buffer(data : PackedByteArray):
	var stream_peer_buffer = StreamPeerBuffer.new()
	var voxel_buffer = VoxelBuffer.new()
	stream_peer_buffer.data_array = data
	serializer.deserialize(stream_peer_buffer, voxel_buffer, data.size(), true)
	return voxel_buffer


func on_client_connected(protocol):
	printt("Client::on_client_connected", protocol)
	WS.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)


func on_client_connection_failed():
	print("Client::on_client_connection_failed - Unable to reach server")


func on_client_disconnected(clean=true):
	print("Client::on_client_disconnected - clean: ", str(clean))


func on_received_data():
	var packet = bytes2var(WS.get_peer(1).get_packet())
	var voxel_buffer = deserialize_voxel_buffer(packet[1])
	match packet[0]:
		Server.PacketType.BLOCK_DATA:
			try_set_block_data(packet[2], voxel_buffer)
		Server.PacketType.VOXEL_BUFFER:
			printt("Client::on_received_data", str(voxel_buffer.get_size()))
			tool.paste(packet[2], voxel_buffer, 1 << VoxelBuffer.CHANNEL_SDF, false)
