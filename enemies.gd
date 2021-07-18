extends Node2D

var count = -1
func grab_id():
	count += 1
	return count #ensures a unique ID for each entity
