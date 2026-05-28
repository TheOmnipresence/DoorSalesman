class_name ClickableDialogue extends NPC


var mouse_hovering := false:
	set(value):
		mouse_hovering = value
		if value:
			$Polygon2D.color = Color(1,1,1,0.2)
		else:
			$Polygon2D.color = Color.TRANSPARENT


func _ready() -> void:
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	mouse_entered.connect(func(): mouse_hovering = true)
	mouse_exited.connect(func(): mouse_hovering = false)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var neighborhood = str(get_parent().get_parent().get_parent().name).to_snake_case()
	if not Globals.houses.has(neighborhood):
		Globals.houses[neighborhood] = {}
	if Globals.houses[neighborhood].has(str(house.name)):
		if not Globals.npc_data.has(str(name).to_snake_case()):
			Globals.npc_data[str(name).to_snake_case()] = {
				"given": false,
				"taken": false,
			}
		if not Globals.npc_data[str(name).to_snake_case()]["given"]:
			Globals.houses[neighborhood][str(house.name)].door = current_door.to_snake_case()
		else:
			current_door = Globals.houses[neighborhood][str(house.name)].door.capitalize()
		Globals.houses[neighborhood][str(house.name)].npc = str(name).to_snake_case()
	house.get_child(0).texture = Globals.make_door_texture(current_door.to_snake_case())
	if override_primary_color != Color.TRANSPARENT and override_secondary_color != Color.TRANSPARENT:
		house.set_colors(override_primary_color, override_secondary_color)


func _process(_delta: float) -> void:
	if mouse_hovering and Input.is_action_just_pressed("mouse1") and not Globals.in_dialogue:
		Globals.in_dialogue = true
		enter_dialouge()
