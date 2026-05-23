extends VBoxContainer

## The door resource associated with this node
var door_res: Globals.Door = null


func _ready() -> void:
	update_info()


func _process(_delta: float) -> void:
	$TakeButton.disabled = len(Globals.truck_inventory) >= Globals.STORAGE_UPGRADES.truck[Globals.truck_storage_level].space and not $TakeButton.text == "Leave"


## Updates the displayed info
func update_info() -> void:
	if door_res != null:
		$Name.text = door_res.door_name
		$Description.text = door_res.description
		$Texture.texture = load("res://Sprites/base_door.png")


func _on_take_button_pressed() -> void:
	if $TakeButton.text == "Bring":
		$TakeButton.text = "Leave"
		Globals.truck_inventory.append(door_res)
	else:
		$TakeButton.text = "Bring"
		Globals.truck_inventory.erase(door_res)
	Globals.update_brought_doors.emit()
