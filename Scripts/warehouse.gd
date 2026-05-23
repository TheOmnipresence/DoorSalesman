extends Control


func _ready() -> void:
	for i in Globals.warehouse_inventory:
		var node = preload("res://Scenes/door.tscn").instantiate()
		node.door_res = i
		node.update_info()
		$HSplitContainer/Tabs/Inventory/ScrollContainer/GridContainer.add_child(node)
