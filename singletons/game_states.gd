extends Node

var states = [
	"idle",
	"gameplay",
	"menu",
	"cutscene",
]

var current_state
var previous_state

func _ready():
	current_state = states[0]

func change_state(new_state):
	previous_state = current_state
	current_state = new_state
