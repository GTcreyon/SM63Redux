extends Label

var frames : int = 0.0

func _process(delta):
	frames += 1.0
	var overall_seconds : float = frames / 60.0
	var ms = floor(fmod(overall_seconds, 1) * 1000)
	var seconds = floor(fmod(overall_seconds, 60))
	var minutes = floor(fmod(overall_seconds, 3600) / 60)
	var hours = floor(overall_seconds / 3600) * 3600
	
	var ms_str = str(ms)
	var seconds_str = str(seconds)
	var minutes_str = str(minutes)
	var hours_str = str(hours)
	
	if ms < 10:
		ms_str = "00" + str(ms_str)
	elif ms < 100:
		ms_str = "0" + str(ms_str)
		
	if seconds < 10:
		seconds_str = "0" + str(seconds_str)
		
	if minutes < 10 && hours > 0:
		minutes_str = "0" + str(minutes_str)
	
	if hours > 0:
		text = "%s:%s:%s.%s" % [hours_str, minutes_str, seconds_str, ms_str]
		margin_right = get_font("font").get_string_size("0:00:00.000").x + 10
	else:
		text = "%s:%s.%s" % [minutes_str, seconds_str, ms_str]
		margin_right = get_font("font").get_string_size("0:00.000").x + 10
	
