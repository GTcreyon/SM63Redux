extends Button

const TEMPLATE_SCENE = preload("res://src/level_designer/template.tscn")
const PLAYER_SCENE = preload("res://actors/player/player.tscn")

onready var main = $"/root/Main"


func _on_Start_pressed():
	var template = $"/root/Main/Template"
	var template_inst = TEMPLATE_SCENE.instance()
	for item in template.get_node("Items").get_children():
		var item_inst = load(main.item_scenes[item.item_name]).instance()
		item_inst.position = item.position
		template_inst.add_child(item_inst)
		
	var terrain = template.get_node("Terrain")
	for item in terrain.get_children():
		terrain.remove_child(item)
		template_inst.add_child(item)
		
	scoop_children(main, template_inst)
	main.add_child(PLAYER_SCENE.instance())
	
	
#this is the main thing i don't like about the current system
#we swap out all of the children of the level designer with the children of the template
#we scooped out the LD's insides and replaced it with the template's insides
#and then continue on like nothing happened
func scoop_children(target: Node, source: Node):
	for child in target.get_children():
		child.queue_free()
	for child in source.get_children():
		source.remove_child(child)
		target.add_child(child)
