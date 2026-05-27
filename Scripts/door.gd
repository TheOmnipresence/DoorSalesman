extends VBoxContainer

## The door resource associated with this node
var door_res: Globals.Door = null

var in_truck := false

var workshop_item := false


func _ready() -> void:
	update_info()


func _process(_delta: float) -> void:
	if in_truck:
		$TakeButton.disabled = len(Globals.carry_inventory) >= Globals.STORAGE_UPGRADES.carry[Globals.carry_storage_level].space and not $TakeButton.text == "Leave"
	else:
		$TakeButton.disabled = len(Globals.truck_inventory) >= Globals.STORAGE_UPGRADES.truck[Globals.truck_storage_level].space and not $TakeButton.text == "Leave"


## Updates the displayed info
func update_info() -> void:
	if door_res != null:
		$Name.text = door_res.item_name
		$Description.text = door_res.description
		$Texture.texture = load("res://Sprites/" + door_res.item_name.to_snake_case() + ".png")
		
		$TakeButton.visible = not workshop_item
		$RepairButton.visible = workshop_item
		$RepairButton.disabled = Globals.array_has_all(Globals.tools, door_res.equipment_needed)
		
		if in_truck:
			if Globals.carry_inventory.has(door_res):
				$TakeButton.text = "Leave"
		else:
			if Globals.truck_inventory.has(door_res):
				$TakeButton.text = "Leave"


func _on_take_button_pressed() -> void:
	if $TakeButton.text == "Bring":
		$TakeButton.text = "Leave"
		if in_truck:
			Globals.carry_inventory.append(door_res)
		else:
			Globals.truck_inventory.append(door_res)
	else:
		$TakeButton.text = "Bring"
		if in_truck:
			Globals.carry_inventory.erase(door_res)
		else:
			Globals.truck_inventory.erase(door_res)
			Globals.carry_inventory.erase(door_res)
	Globals.update_brought_doors.emit()


func _on_repair_button_pressed() -> void:
	Globals.warehouse_inventory.erase(door_res)
	Globals.truck_inventory.erase(door_res)
	Globals.carry_inventory.erase(door_res)
	Globals.warehouse_inventory.append(Globals.make_door_by_name(door_res.repair_to_door))
	Globals.money -= door_res.repair_cost
	queue_free()
	get_tree().current_scene.update_all()
