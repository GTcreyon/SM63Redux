extends Node

var classic = true

####the following lines are for the coins collected in the GUI
var coins_total = 0
var red_coins_total = 0 #specifically for red coins

onready var coin_counter_string = find_node("Coin_counter") #note: this is to get ONLY the Coin_counter node from the GUI
onready var red_coin_counter_string = find_node("Red_coin_counter") #specifically for red coins
onready var coin_audio_sfx = find_node("Coin_sfx")

func _on_Coin_body_entered_collected(_body): #custom node method made in this scene and it's connected to the main node
	coin_audio_sfx.play()
	coins_total += 1
	
	coin_counter_string.text = str(coins_total) #str() converts the int variable to string, changing the number in Coin_counter

#the next function signals are for the non yellow coins

func _on_Coin_red_body_entered_increment(_body):
	#this whole thing has extra stuff
	#for the red coins
	coin_audio_sfx.play()
	
	red_coins_total += 1
	coins_total += 2
	
	red_coin_counter_string.text = str(red_coins_total)
	coin_counter_string.text = str(coins_total)


func _on_Coin_blue_body_entered_increment(_body):
	#same as yellow coins, but increments 5
	#instead of 1
	coin_audio_sfx.play()
	coins_total += 5
	
	coin_counter_string.text = str(coins_total)

####End of the lines for coin collect handle in this script
