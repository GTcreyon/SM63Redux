extends AudioStreamPlayer

onready var fade_out = $FadeOut
onready var fade_in = $FadeIn

const song_1 = preload("res://audio/music/ld/editor1.ogg")
const song_2 = preload("res://audio/music/ld/editor2.ogg")
const song_3 = preload("res://audio/music/ld/editor3.ogg")
const song_4 = preload("res://audio/music/ld/editor4.ogg")

const song_list = [song_1, song_2, song_3, song_4]

var song_length
var play_length
var length_factor
var song_num

func switch_song():
	song_num = (song_num + 1 + (randi() % 3)) % 4
	stream = song_list[song_num]
	play(0)
	fade_in.interpolate_property(self, "volume_db", -60, 0, 5, 1, Tween.EASE_OUT)
	fade_in.start()
	song_length = stream.get_length()
	length_factor = rand_range(1, 3)
	#length_factor = 0.3
	play_length = song_length * length_factor
	fade_out.interpolate_property(self, "volume_db", 0, -60, 10, 1, Tween.EASE_IN, play_length)
	fade_out.start()


func _ready():
	randomize()
	song_num = randi() % 4
	volume_db = -80
	switch_song()


func _on_FadeOut_tween_completed(_object, _key):
	# stop the music -- otherwise it continues to run at silent volume
	stop()
	switch_song()
