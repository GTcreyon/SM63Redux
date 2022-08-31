extends Button

const TEMPLATE_SCENE = preload("./template.tscn")
const PLAYER_SCENE = preload("res://classes/player/player.tscn")
const BG_SCENE = preload("res://scenes/levels/tutorial_1/bg/bg_t1.tscn")

onready var main = $"/root/Main"
onready var save = $"/root/Main/UILayer/SaveDialog"


func _on_Start_pressed():
	var serializer = Serializer.new()
	Singleton.ld_buffer = serializer.generate_level_binary($"/root/Main/Template/Items".get_children(), $"/root/Main/Template/Terrain".get_children(), main)
	var template = $"/root/Main/Template"
	var template_inst = TEMPLATE_SCENE.instance()
	for item in template.get_node("Items").get_children():
		var item_inst = load(main.item_scenes[item.item_id]).instance()
		template_inst.add_child(item_inst)
		apply_properties(item_inst, item)
		
	var terrain = template.get_node("Terrain")
	for item in terrain.get_children():
		terrain.remove_child(item)
		template_inst.add_child(item)
		
	scoop_children(main, template_inst)
	main.add_child(PLAYER_SCENE.instance())
	main.add_child(BG_SCENE.instance())
	main.in_level = true


func apply_properties(inst, item_data) -> void:
	inst.position = item_data.position
	for key in item_data.properties:
		var prop = item_data.properties[key]
		var var_name = main.items[item_data.item_id].properties[key].var_name
		if var_name == null: # default value, no var name specified
			var_name = to_var_name(key)
		inst.set(var_name, prop)


func to_var_name(label: String) -> String:
	return label.to_lower().replace(" ", "_")

# this is the main thing i don't like about the current system
# we swap out all of the children of the level designer with the children of the template
# we scooped out the LD's insides and replaced it with the template's insides
# and then continue on like nothing happened
func scoop_children(target: Node, source: Node):
	for child in target.get_children():
		child.queue_free()
	for child in source.get_children():
		source.remove_child(child)
		target.add_child(child)
