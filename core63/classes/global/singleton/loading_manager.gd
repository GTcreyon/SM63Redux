extends Node

#This node is used to load resources in the background on runtime.
#Meant to be used for loading mods, but can be used for basically any resource as well.

var thread #thread container
var queue = [] #-> ["path", [nodes]]

var loader = ResourceInteractiveLoader.new() #loader container

signal resource_loaded

#Called when the node enters the scene tree for the first time.
func _globalobject_ready():
	thread = Thread.new()

#This script can get kind of confusing, so I'll try to explain it as best as possible.

#Pass the ResourcePath and a self reference
#Use this to load paths! This is the frontend function for this manager
#This function just loads resource paths into the loading queue. No actual loading is done here.
#'path' is the resource path, 'nodes' are an array of references to the nodes requesting this resource.
func load_resource(path : String, nodes : Array):
	for res in queue: #iterates over the entire queue
		if res[0] == path: #if the path is already in the queue...
			for i in res[1]: #check the reciever nodes for that path
				if nodes.has(i): #if there's a duplicate reciever...
					nodes.erase(i) #erase it from the incoming reciever nodes array
			res[1].append_array(nodes) #now merge the reciever nodes into the queue entry
		else: #if the queue doesn't have this resource path...
			queue.append([path, nodes]) #add it to the queue!
	if queue.empty() || !thread.is_active(): #if the loading thread hasn't started yet...
		thread.start(self, "_thread_function") #start it!

#This is the 'core' function of the manager.
#This doesn't actually need a path or node reference to function
#It just loads from the bottom of the queue (slot 0)
#If nothing is there, the function exits.
func _thread_function():
	loader = ResourceLoader.load_interactive(queue[0][0]) #Starts the loading process
	if loader == null: #If a loading error occurs (likely the path is not found)...
		queue.remove(0) #remove the item from the queue
		call_deferred("check_queue") #check the queue on the next thread sync
		return
	var max_load_time = 1500 #(in ms) arbitrary number, equal to 1.5 seconds
	var t = OS.get_ticks_msec() #current time when loading starts
	while (OS.get_ticks_msec() < t + max_load_time) || loader != null:
	#while not timed out or no loading errors (or exits) appear...

		var err = loader.poll() #grab some more resource data!
		if err == ERR_FILE_EOF: #if the file is finished loading...
			var resource = loader.get_resource() #instance it!
			loader = null #kill the loader.
			for recieving_node in queue[0][1]: #iterates on all recieving nodes
				recieving_node.call_deferred("_resource_loaded", queue[0][0], resource)
				#calls each reciever node's "_resource_loaded" function
				#(IMPORTANT!!) ALL RECIEVER NODES SHOULD EITHER BE A BASEOBJECT OR HAVE A _RESOURCE_LOADED FUNCTION
			queue.remove(0) #Remove the loaded resouce from the queue
			break

		elif err == OK: #Everything's good so far! Keep loading!
			pass

		else: #Anything else happen? Treat it as an error.
			loader = null
			break

	call_deferred("check_queue") #check the queue on the next thread sync
	#the check_queue function is needed just in case the loader stops just before another resource is queued
	
	#Notifies of a timeout error.
	if OS.get_ticks_msec() < t + max_load_time && loader != null:
		call_deferred("push_error", "loading_manager: Load failed. %s timed out" % queue[0][0])
		queue.remove(0)
	return

func check_queue():
	if !queue.empty():
		thread.start(self, "_thread_function", queue[0][0], queue[0][1])
