extends AudioStreamPlayer


const song_1 = preload("./music/editor1.ogg")
const song_2 = preload("./music/editor2.ogg")
const song_3 = preload("./music/editor3.ogg")
const song_4 = preload("./music/editor4.ogg")

const song_list = [song_1, song_2, song_3, song_4]

var fade_out: Tween
var fade_in: Tween

var song_length
var play_length
var length_factor
var song_num


func _ready():
	randomize()
	song_num = randi() % 4
	volume_db = -80
	switch_song()


func switch_song():
	fade_in = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fade_out = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade_out.finished.connect(Callable(self, "_on_FadeOut_tween_completed"))
	
	# Play a song at random.
	song_num = (song_num + 1 + (randi() % 3)) % 4
	stream = song_list[song_num]
	play(0)
	
	fade_in.tween_property(
		self, "volume_db",
		0, # target value
		5 # duration
	).from(-60) # start value
	
	song_length = stream.get_length()
	length_factor = randf_range(1, 3)
	#length_factor = 0.3
	play_length = song_length * length_factor
	fade_out.tween_property(
		self, "volume_db",
		-60,
		10
	).from(0).set_delay(play_length)


func _on_FadeOut_tween_completed():
	# stop the music -- otherwise it continues to run at silent volume
	stop()
	switch_song()
