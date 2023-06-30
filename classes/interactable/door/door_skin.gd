@tool
class_name DoorSkin
extends SpriteFrames

# Solid-choice fallback constants in case a skin is loaded with no script.
const DEFAULT_PLAYER_FADE_START : int = 20
const DEFAULT_PLAYER_FADE_RATE : float = 0.1
const DEFAULT_DOOR_CLOSE_START : int = 20

@export (int, 0, 60) var player_fade_start_time = DEFAULT_PLAYER_FADE_START
@export (float, 0, 1, 0.1) var player_fade_rate = DEFAULT_PLAYER_FADE_RATE
@export (int, 0, 60) var door_close_start_time = DEFAULT_DOOR_CLOSE_START
