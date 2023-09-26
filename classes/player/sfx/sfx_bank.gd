extends Resource
class_name SFXBank

@export var sound_bank : Array[AudioStreamWAV]
@export var group_bank : Dictionary
# Notes: I'm duplicating the spins and putting them in a folder
# I do not recommend deleting them for now, the paths are hardcoded
# Just let them stay there until we refactor the actual player script

# A couple of the AudioStream files are AudioStreamMP3
# The typed array does not like having these with AudioStreamWAV
# I will leave them out for now, would they be fine as WAV format?

# The pound sfx files are all named
# Because of this, I'm not sure how good an array fits them
# We have 5 solutions to this as far as I can think of
# 1. Continue using them in an array (We would need to remember the indices)
# 2. Convert sound_bank to a dictionary (Cannot be typed, useless for every other sound)
# 3. Use group_bank to store them (We would need a new function for returning sounds)
# 4. Create a new dictionary for named sounds (Potentially a waste of resources)
# 5. Make a new resource for each named pound (Same as 4 but could be useful in future if we make more pound sounds)

# Also, the main sfx.tres resource has groups and sounds
# I'm using this as a way to store misc. sounds like step_ice_squeak and spin_water_end
# I don't feel like those fit with the rest of their siblings (step_ice_0, 1, 2, etc.)


# Right now I don't see any point in adding settters
# If you come up with a reason to change a bank at runtime, you can add them
func get_group(key) -> SFXBank:
	return group_bank[key]


func get_sound(idx) -> AudioStreamWAV:
	return sound_bank[idx]
