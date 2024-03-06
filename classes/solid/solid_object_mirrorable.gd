class_name SolidObjectMirrorable
extends SolidObject
## A StaticBody2D which can be both disabled or mirrored in the level designer.

static var mirrored_shapes: Dictionary = {}
static var unmirrored_shapes: Dictionary = {}

@export var mirror = false: set = set_mirror


func set_mirror(val):
	# Store whether the new value is DIFFERENT from the old.
	# This allows several things to flip correctly without storing their
	# old positions.
	var changed = val != mirror
	
	# Write to the mirroring value itself.
	mirror = val
	
	# If mirroring didn't change, no child nodes need to be processed. Abort.
	if !changed:
		return
	
	# If mirroring did change, flip all children.
	for child in get_children():
		# Flip any child's transformation.
		if child is Node2D:
			(child as Node2D).position.x *= -1
			(child as Node2D).rotation *= -1
		
		# If the child has its own mirroring logic, fall through into that.
		if child.has_method("set_mirror"):
			child.set_mirror(mirror)
			# Assume this child has handled all it needed to, and go to next.
			continue
		
		# Flip sprites.
		if child is Sprite2D or child is AnimatedSprite2D:
			child.flip_h = !child.flip_h if changed else child.flip_h
		
		# Flip polygons and collision polygons, which conveniently share an
		# interface as of Godot 4.1.
		elif child is Polygon2D or child is CollisionPolygon2D:
			child.polygon = flip_points(child.polygon)
		
		# Flip collision shapes that can flip.
		elif child is CollisionShape2D:
			var shape := (child as CollisionShape2D).shape
			if changed and mirror:
				# On becoming mirrored, make a copy of the shape resource
				# so we can mirror its data without messing up any other users
				# of the shape resource (yes, the shapes are resources!).
				shape = shape.duplicate()
				child.shape = shape.duplicate()
				# Resources are reference-counted, and theoretically every
				# duplicate is unique to the object that created it--meaning
				# old duplicates should automatically be deleted and it 
				# shouldn't become a memory leak.
				# If that's not the case (or having a separate mirrored copy
				# for every mirrored solid becomes a problem), a more complex
				# solution involving static dictionaries may be in order.
				# Admittedly, the current solution was chosen for its simplicity
				# more than its optimalcy.
			
			# Line segment with two points. Invert X of both points.
			if shape is SegmentShape2D:
				(shape as SegmentShape2D).a.x *= -1
				(shape as SegmentShape2D).b.x *= -1
			# Infinite boundary. Invert the normal on the X axis.
			elif shape is WorldBoundaryShape2D:
				(shape as WorldBoundaryShape2D).normal.x *= -1
			# Convex polygon. Invert all points' X.
			elif shape is ConvexPolygonShape2D:
				var polygon := shape as ConvexPolygonShape2D
				polygon.points = flip_points(polygon.points)
			# Concave polygon. Invert all points' X.
			elif shape is ConcavePolygonShape2D:
				var polygon := shape as ConcavePolygonShape2D
				polygon.segments = flip_points(polygon.segments)
			# No other collision shape has information which needs flipping.
		
		# That should cover all types of nodes that a solid object is likely
		# to contain.


func flip_points(points: PackedVector2Array) -> PackedVector2Array:
	# Invert X of all points.
	for i in points.size():
		points[i].x *= -1
	return points
