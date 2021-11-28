extends Polygon2D

func _ready():
	$Area2D/CollisionPolygon2D.polygon = polygon


func _on_Area2D_body_entered(body):
	$"/root/Main/Player".take_damage(8)
