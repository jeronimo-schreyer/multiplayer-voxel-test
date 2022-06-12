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
