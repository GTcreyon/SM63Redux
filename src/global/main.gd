extends Node

var classic = true

#the following lines are for the coins collected in the GUI
var coins_total = 0

onready var coin_counter_string = get_node("Player/Camera2D/GUI/Coin_counter") #note: this is to get ONLY the Coin_counter node from the GUI

func _on_Coin_body_entered_collected(body): #custom node method made in this scene and it's connected to the main node
	coins_total += 1
	
	coin_counter_string.text = str(coins_total) #str() converts the int variable to string, changing the number in Coin_counter
	
	pass # Replace with function body.

#End of the lines for coin collect handle in this script
