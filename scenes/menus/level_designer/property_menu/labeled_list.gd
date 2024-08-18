@tool
class_name LabeledList
extends Container
## A container that arranges its child controls vertically, and shows their
## names as labels on the left.

## Prefix prepended to the name of label nodes.
const LABEL_PREFIX = "__label_"

var ready_done = false

var node_labels = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create a label for all children.
	for child in get_children(false):
		_label_child(child)
	
	# Ensure later-added nodes get the same treatment.
	child_entered_tree.connect(Callable(self, &"_label_child"))
	# Clean up after nodes being removed from the tree.
	child_exiting_tree.connect(Callable(self, &"_delabel_child"))


func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Get the width of the widest label.
		var label_max_wid = 0
		for label: Label in node_labels.values():
			label_max_wid = max(label.size.x, label_max_wid)
		# Find the widest min width out of all user-added child controls.
		var ctl_max_wid = 0
		for ctl: Control in node_labels.keys(): # arrgh misuse of dictionary
			ctl_max_wid = max(ctl.get_minimum_size().x, ctl_max_wid)
		
		# Decide the size of the columns.
		# When the controls and the labels combined are too wide to fit,
		# shrink the labels so the controls fit.
		var label_wid = min(label_max_wid, size.x - ctl_max_wid)
		# TODO: fancier algorithms can get the labels more even by using the
		# widest width *within one standard deviation of the mean*. Skipping
		# long outliers and forcing them to linewrap, y'know?
		
		# If the min size of the controls *and* the labels is too big,
		# size up the container.
		# TODO: Mission critical! Actually implement this!
		
		var next_y = 0
		var spacing = get_theme_constant(&"v_separation", &"LabeledList")
		# Place the children and their labels.
		for child in get_children(false):
			# Skip non-Control children.
			if not (child is Control):
				continue
			# By excluding internal children, we don't have to worry about
			# skipping labels.
			
			var control := child as Control
			var label: Label = node_labels[child]
			
			var ctl_rect = Rect2(label_wid, next_y, self.size.x - label_wid, control.get_minimum_size().y)
			var label_rect = Rect2(0, next_y, label_wid, control.get_minimum_size().y)
			
			fit_child_in_rect(control, ctl_rect)
			fit_child_in_rect(label, label_rect)
			
			next_y += ctl_rect.size.y + spacing


func _label_child(child: Node):
	# Skip non-Control children.
	if not (child is Control):
		return
	# Skip labels--they're children too!
	if child.name.begins_with(LABEL_PREFIX):
		return
	
	var label_name = LABEL_PREFIX + child.name
	
	# Create the label node.
	var label := Label.new()
	label.name = label_name
	label.text = child.name
	label.theme = self.theme
	# Add it as an internal node.
	add_child(label, false, Node.INTERNAL_MODE_FRONT)
	
	# Save a link from the child to the node.
	# TODO: Verify that this is faster than doing get_node repeatedly.
	# Intuition suggests that hashmap lookup would be faster than whatever
	# Godot is doing with paths, but cold hard data always trumps intuition.
	node_labels[child] = label


func _delabel_child(child: Node):
	# Skip non-Control children.
	if not (child is Control):
		return
	# Skip labels--they're children too!
	if child.name.begins_with(LABEL_PREFIX):
		return
	
	# Queue the label for deletion.
	remove_child.call_deferred(node_labels[child])
	node_labels[child].queue_free()
	# Clean up the saved link from this child to its label.
	node_labels.erase(child)
