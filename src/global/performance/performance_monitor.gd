extends Node

var data: Dictionary = {}
var fps_lag: int = 0
var physics_lag: int = 0
var max_fps: int = 60
var print_delay: int = 0
var streak_id: int = 0

func _physics_process(delta):
	if OS.get_ticks_msec() > 3000:
		var fps = Performance.get_monitor(Performance.TIME_FPS)
		var time_physics = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		
		# warning-ignore:narrowing_conversion
		max_fps = max(fps, max_fps)
		if fps < max_fps - 1:
			fps_lag += 1
		else:
			fps_lag = 0
			
		if Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) > delta:
			physics_lag += 1
		else:
			physics_lag = 0
			
		if fps_lag % 60 == 10:
			print("FPS lag. FPS:%d Max:%d" % [fps, max_fps])
		
		if physics_lag % 60 == 1:
			print("PHYSICS lag. Loss:%f Delta:%f" % [
				(time_physics - delta),
				delta
				])
		if Input.is_action_just_pressed("dump"):
			print_data()


func print_data():
	print(JSON.print(dump_data()))


func dump_data() -> Dictionary:
	return {
		"fps":Performance.get_monitor(Performance.TIME_FPS),
		"process":Performance.get_monitor(Performance.TIME_PROCESS),
		"physics":Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"objects":Performance.get_monitor(Performance.OBJECT_COUNT),
		"resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		"render_items":Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME),
		"draw_calls":Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME),
		"mem_texture":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"mem_vertex":Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED),
		"rigids":Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
		"pairs":Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
		"islands":Performance.get_monitor(Performance.PHYSICS_2D_ISLAND_COUNT),
		"latency":Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY),
	}
