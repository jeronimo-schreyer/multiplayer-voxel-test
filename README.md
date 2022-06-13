# multiplayer-voxel-test

Minimal test project using [Zylann's](https://github.com/Zylann) [Voxel plugin](https://github.com/Zylann/godot\_voxel) [Multiplayer API](https://voxel-tools.readthedocs.io/en/latest/multiplayer/) on a Websocket connection

### Prerequisites

* Godot Engine 4 built with the voxel plugin
  ```
  $ git clone https://github.com/godotengine/godot.git
  $ git clone https://github.com/Zylann/godot_voxel.git voxel
  $ cd godot
  $ scons p=linuxbsd target=release_debug tools=yes custom_modules="../voxel"
  ```
  Change the `p` parameter to your platform. You can use `-j$(nproc)` to use multithreaded building.

### How to use?

Start the game with more than one instance (**Debug->Run Multiple Instances**).\
Acording to the Multiplayer API documentation, server should be authoritative and the clients just receive information from it. So, to edit the terrain, click on it using the server
