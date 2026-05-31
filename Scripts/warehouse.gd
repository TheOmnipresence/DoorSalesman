extends Control

var window_theme := Theme.new()


func _ready() -> void:
	for i in $HSplitContainer/SideBar/TabButtons.get_children():
		i.pressed.connect(set_current_tab.bind(str(i.name)))
	
	$HSplitContainer/Tabs/Map/BankruptButton.pressed.connect(Globals.go_bankrupt)
	
	Globals.update_brought_doors.connect(update_brought_doors)
	#for i in Globals.all_doors.map(func(e: Globals.Door): return "\"" + e.item_name + "\": " + str(e.sell_for) + ","):
		#print(i)
	#for i in Globals.shop_inventory:
		#print(i.item_name + ", " + str(i.cost))
	update_all()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse2"):
		Globals.money += 100


func update_all() -> void:
	update_brought_doors()
	
	force_update_doors()
	
	force_update_upgrades()
	
	update_map()
	
	update_disabled_tabs()
	
	update_workshop()
	
	get_window().theme = window_theme
	get_window().theme_changed.connect(func(): if get_window().theme != window_theme: get_window().theme = window_theme)
	
	$HSplitContainer/Tabs/Shop/Money.text = "Money: " + str(Globals.money)


func force_update_doors() -> void:
	for i in $HSplitContainer/Tabs/Storage/ScrollContainer/GridContainer.get_children():
		i.queue_free()
	
	for i in Globals.warehouse_inventory:
		var node = preload("res://Scenes/door.tscn").instantiate()
		node.door_res = i
		node.update_info()
		$HSplitContainer/Tabs/Storage/ScrollContainer/GridContainer.add_child(node)
	
	for i in $HSplitContainer/Tabs/Inventory/ScrollContainer/GridContainer.get_children():
		i.queue_free()
	
	for i in Globals.truck_inventory:
		var node = preload("res://Scenes/door.tscn").instantiate()
		node.door_res = i
		node.in_truck = true
		node.update_info()
		$HSplitContainer/Tabs/Inventory/ScrollContainer/GridContainer.add_child(node)


func force_update_upgrades() -> void:
	for i in $HSplitContainer/Tabs/Shop/ScrollContainer/GridContainer.get_children():
		i.queue_free()
	
	for i in Globals.shop_inventory:
		if Globals.items_collected_from_shop.has(i):
			continue
		if i is Globals.Storage and not Globals.is_archipelago:
			for type in Globals.STORAGE_UPGRADES:
				if Globals.STORAGE_UPGRADES[type].has(i):
					if Globals.get(type + "_storage_level") + 1 < Globals.STORAGE_UPGRADES[type].find(i):
						continue
		#if i is Globals.Storage:
			#var kind = ""
			#for type in Globals.STORAGE_UPGRADES:
				#if Globals.STORAGE_UPGRADES[type].has(i):
					#kind = type
			#
			#if Globals.get(kind + "_storage_level") >= Globals.STORAGE_UPGRADES[kind].find(i):
				#continue
		
		if Globals.visited.has(i.shipment):
			var node = preload("res://Scenes/item.tscn").instantiate()
			node.item_res = i
			node.update_info()
			$HSplitContainer/Tabs/Shop/ScrollContainer/GridContainer.add_child(node)


func update_workshop() -> void:
	for i in $HSplitContainer/Tabs/Workshop/ScrollContainer/GridContainer.get_children():
		i.queue_free()
	
	for i in Globals.warehouse_inventory:
		if i.repair_cost > -1:
			var node = preload("res://Scenes/door.tscn").instantiate()
			node.door_res = i
			node.workshop_item = true
			$HSplitContainer/Tabs/Workshop/ScrollContainer/GridContainer.add_child(node)


func set_current_tab(tab_name: String) -> void:
	for i in $HSplitContainer/Tabs.get_children():
		i.hide()
	
	if $HSplitContainer/Tabs.has_node(tab_name):
		$HSplitContainer/Tabs.get_node(tab_name).show()


func update_brought_doors() -> void:
	for i in $HSplitContainer/Tabs/Map/BroughtDoors.get_children():
		if str(i.name) != "Heading":
			i.queue_free()
	
	for i in Globals.truck_inventory:
		var node = Label.new()
		node.text = "- " + i.item_name
		$HSplitContainer/Tabs/Map/BroughtDoors.add_child(node)
	
	if Globals.truck_inventory.is_empty() and not Globals.warehouse_inventory.is_empty():
		$HSplitContainer/Tabs/Map/BroughtDoors.add_child(create_warning_label("! No doors selected !"))
	elif len(Globals.truck_inventory) < Globals.STORAGE_UPGRADES.truck[Globals.truck_storage_level].space and len(Globals.warehouse_inventory) > len(Globals.truck_inventory):
		$HSplitContainer/Tabs/Map/BroughtDoors.add_child(create_warning_label("! You can fit more doors !"))


func create_warning_label(text: String) -> Label:
	var node = Label.new()
	node.text = text
	node.label_settings = LabelSettings.new()
	node.label_settings.font_color = Color.YELLOW
	return node


func update_map() -> void:
	var reachable = get_reachable_neighborhoods("warehouse")
	
	for button in $HSplitContainer/Tabs/Map/Map/Buttons.get_children():
		button.disabled = not reachable.has(str(button.name).to_snake_case())
		for i in button.connections:
			var line = Line2D.new()
			line.add_point(button.position + (button.size / 2))
			line.add_point(i.position + (i.size / 2))
			$HSplitContainer/Tabs/Map/Map/Lines.add_child(line)


func update_disabled_tabs() -> void:
	var in_warehouse = Globals.current_space == "warehouse"
	$HSplitContainer/SideBar/TabButtons/View.disabled = in_warehouse
	$HSplitContainer/SideBar/TabButtons/Inventory.disabled = in_warehouse
	$HSplitContainer/SideBar/TabButtons/Storage.disabled = not in_warehouse
	$HSplitContainer/SideBar/TabButtons/Shop.disabled = not (Globals.got_money and in_warehouse)
	$HSplitContainer/SideBar/TabButtons/Workshop.disabled = not (not Globals.tools.is_empty() and in_warehouse)


func get_reachable_neighborhoods(neighborhood_name: String) -> Array[String]:
	var result: Array[String] = []
	result.append(neighborhood_name)
	if Globals.availible_spaces.has(neighborhood_name):
		for i in $HSplitContainer/Tabs/Map/Map/Buttons.get_node(neighborhood_name.to_pascal_case()).connections:
			for new in get_reachable_neighborhoods(str(i.name).to_snake_case()):
				if Globals.availible_spaces.has(new):
					result.append(new)
	return result
