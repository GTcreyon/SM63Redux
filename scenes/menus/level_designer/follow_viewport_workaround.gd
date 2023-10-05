extends CanvasLayer

# As of godot 3.5, buttons inside of a canvaslayer with follow viewport enabled do not work
# So this is basically a script which makes the canvaslayer follow the viewport with it still working
# TODO: Game is on 4.1 now. Check if this is still true.

@onready var camera = $"/root/Main/Camera"


func _process(_dt):
	transform.origin = -camera.position
