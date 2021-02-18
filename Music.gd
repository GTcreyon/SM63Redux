extends AudioStreamPlayer;

onready var fadeOut = $FadeOut;
onready var fadeIn = $FadeIn;

const song1 = preload("res://Audio/Music/LD/editor1.ogg");
const song2 = preload("res://Audio/Music/LD/editor2.ogg");
const song3 = preload("res://Audio/Music/LD/editor3.ogg");
const song4 = preload("res://Audio/Music/LD/editor4.ogg");

const songList = [song1, song2, song3, song4];

var songLength;
var playLength;
var lengthFactor;
var songNum;

func switch_song():
	songNum = (songNum + 1 + (randi() % 3)) % 4;
	stream = songList[songNum];
	play(0);
	fadeIn.interpolate_property(self, "volume_db", -60, 0, 5, 1, Tween.EASE_OUT);
	fadeIn.start();
	songLength = stream.get_length();
	lengthFactor = rand_range(1, 3);
	#lengthFactor = 0.3;
	playLength = songLength * lengthFactor;
	fadeOut.interpolate_property(self, "volume_db", 0, -60, 10, 1, Tween.EASE_IN, playLength);
	fadeOut.start();

#func _process(delta):
#	if get_playback_position() > playLength + 10:
#

func _ready():
	randomize();
	songNum = randi() % 4;
	volume_db = -80;
	switch_song();
	
func _on_FadeOut_tween_completed(object, key):
	# stop the music -- otherwise it continues to run at silent volume
	stop();
	switch_song();
