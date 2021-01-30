extends AnimatedSprite

var code = "";

func _ready():
	$Label.text = code;
	var data = code.split(",");
	position = Vector2(int(data[1]) + 32, int(data[2]) + 32);
	animation = data[0];
	if data[0] == "140":
		rotation_degrees = int(data[4]);

func _process(delta):
	pass
