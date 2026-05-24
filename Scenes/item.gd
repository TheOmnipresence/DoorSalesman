extends VBoxContainer


#func update_info() -> void:
	#if door_res != null:
		#$Name.text = door_res.door_name
		#$Description.text = door_res.description
		#$Texture.texture = load("res://Sprites/" + door_res.door_name.to_snake_case() + ".png")
		#
		#if in_truck:
			#if Globals.carry_inventory.has(door_res):
				#$TakeButton.text = "Leave"
		#else:
			#if Globals.truck_inventory.has(door_res):
				#$TakeButton.text = "Leave"
