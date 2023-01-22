extends Node

class_name CharacterInventory

#This class contains all the variables for powerups and FLUDD nozzles the player currently has.

#Powerup variables
var powerup_stack: Array = [] #List of all active powerups


#FLUDD variables
var has_fludd: bool = false
export(int) var max_fuel: int = 100
var fuel: int = max_fuel #FLUDD tank


func get_current_powerups():
	var  rtv #rtv = return var
	for i in powerup_stack:
		rtv.append(i.name)
	return rtv
