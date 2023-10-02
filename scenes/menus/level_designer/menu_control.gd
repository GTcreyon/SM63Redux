extends Control

@onready var item_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid
@onready var polygon_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/PolygonGrid


func _on_Mode_pressed():
	item_grid.visible = !item_grid.visible
	polygon_grid.visible = !item_grid.visible
