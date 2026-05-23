extends Control


func _ready() -> void:
	for i in $HSplitContainer/TabButtons.get_children():
		i.pressed.connect(set_current_tab.bind(str(i.name)))
	
	force_update_doors()


func force_update_doors():
	for i in $HSplitContainer/Tabs/Storage/ScrollContainer/GridContainer.get_children():
		i.queue_free()
	
	for i in Globals.warehouse_inventory:
		var node = preload("res://Scenes/door.tscn").instantiate()
		node.door_res = i
		node.update_info()
		$HSplitContainer/Tabs/Storage/ScrollContainer/GridContainer.add_child(node)


func set_current_tab(tab_name: String) -> void:
	for i in $HSplitContainer/Tabs.get_children():
		i.hide()
	
	if $HSplitContainer/Tabs.has_node(tab_name):
		$HSplitContainer/Tabs.get_node(tab_name).show()
