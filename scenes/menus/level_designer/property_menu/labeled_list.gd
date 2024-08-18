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
		pass


func _label_child(child: Node):
	# Skip non-Control children.
	if not (child is Control):
		return
	# Skip labels--they're children too!
	if child.name.begins_with(LABEL_PREFIX):
		return
	
	var label_name = LABEL_PREFIX + child.name
	
	# Reuse the existing label for this child if it already exists
	# (which could happen if the child was removed, then a new child with the
	# same name was added before the old one's label could be freed).
	# Get by name instead of indexing the dictionary, since the old node itself
	# (and its dictionary entry) is long gone.
	var label = get_node_or_null(label_name)
	if label != null:
		# Old label still exists. Make sure it sticks around so we can use it.
		# (By creating it fresh, we would risk a name collision in this case.)
		label.cancel_free()
	else:
		# Create the label node.
		label = Label.new()
		label.name = label_name
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
	node_labels[child].queue_free()
	# Clean up the saved link from this child to its label.
	node_labels.erase(child)
