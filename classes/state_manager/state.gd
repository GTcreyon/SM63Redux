extends Node

class_name State

#different error reasons that can be thrown when a call is denied
enum error {
	ERROR_START_CONDITIONS_NOT_MET,
	ERROR_STOP_CONDITIONS_NOT_MET,
	ERROR_STATE_BUSY, #reserved, likely to be for when a state-spawned thread is not finished processing
	ERROR_STATE_BLACKLISTED,
	ERROR_STATE_NOT_FOUND
	}

var category: String = "unknown" #The category tag for this state. Useful for blacklisting every state inside a category.

var message: Dictionary = {} #a cotainer for variables being passed on while states are changing

var blacklist: Array #takes names of states forbidden to change to from the current one


func _state_init():
	pass


func _check_start_conditions(): #if true, the state will start. Most of the time will not be necessary.
	return true #if not true, be sure to return an error


func _start(): #initialization for the state
	pass
	
func _check_stop_conditions(): #if true, the state will stop and return to the default state. Most of the time will not be necessary.
	return true #if not true, be sure to return an error


func _stop(): #final commands before stopping
	pass


func _update(_delta): #basically just _physics_process. State transition logic should also be done here (for now)
	pass
