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
				"first": true,
			}
		if Globals.npc_data[str(name).to_snake_case()]["first"]:
			Globals.houses[neighborhood][str(house.name)].door = current_door.to_snake_case()
			Globals.npc_data[str(name).to_snake_case()]["first"] = false
		else:
			current_door = Globals.houses[neighborhood][str(house.name)].door.capitalize()
		Globals.houses[neighborhood][str(house.name)].npc = str(name).to_snake_case()
	house.get_child(0).texture = Globals.make_door_texture(current_door.to_snake_case())
	if override_primary_color != Color.TRANSPARENT and override_secondary_color != Color.TRANSPARENT:
		house.set_colors(override_primary_color, override_secondary_color)
	
	set_tree()


func _process(_delta: float) -> void:
	if mouse_hovering and Input.is_action_just_pressed("mouse1") and not Globals.in_dialogue:
		Globals.in_dialogue = true
		enter_dialouge()


func set_tree() -> void:
	var adding = {
		"/": Dialouge.new_from_dict({
			"action_condition":DialougeActionTransition.new(DialougeActionTransition.types.TRANSITION, "Data." + str(name).to_snake_case() + ".given", OP_NOT)
		}),
		"/ask/": Dialouge.new(
			"q",
			"Walk up?",
			[Dialouge.new("y","Yes",[],DialougeActionTransition.new(DialougeActionTransition.types.TRANSITION, "Globals.carry_inventory", OP_NOT_EQUAL, [])),
			Dialouge.new("n","No")]
		),
		"/ask/y/": Dialouge.new("knock?", "Knock?", [Dialouge.new("y","Yes"), Dialouge.new("n","No")]),
		"/ask/y/y/": Dialouge.new("knock"),
		"/ask/y/y/true/": Dialouge.new_from_dict({"set_dia_path": "/y/"}),
		"/false/": Dialouge.new_from_dict({"action_condition": DialougeActionTransition.new(DialougeActionTransition.types.TRANSITION, "Data." + str(name).to_snake_case() + ".taken", OP_MAX, null, true)}),
		"/false/true/": Dialouge.new("take_old"),
		"/false/true/take_old/": Dialouge.new("yay", "Here, take the old one"),
		"/true/": Dialouge.new_from_dict({"set_dia_path": "/ask/"}),
		"/y/": Dialouge.new("greet", "Hello", [Dialouge.new("show", "Hello, would you like to see a door?"), Dialouge.new("hi", "Hi")]),
		"/y/show/": Dialouge.new_from_dict({
			"key": "sure",
			"text": "What door?",
			"options_doors": true,
		}),
		"/y/show/bad_door/": Dialouge.new("ew", "I don't really like that one...", [Dialouge.new("ew","...")]),
		"/y/show/bad_door/ew/": Dialouge.new("more", "Do you have any more?", [
			Dialouge.new("n", "No"),
			Dialouge.new("y", "Yeah")
		]),
		"/y/show/bad_door/ew/y/": Dialouge.new_from_dict({"set_dia_path": "/y/show/"}),
		"/y/show/good_door/": Dialouge.new("cool", "Thanks", [], DialougeActionTransition.new(DialougeActionTransition.types.TRANSITION, "Data." + str(name).to_snake_case() + ".given", OP_MAX, true)),
	}
	for i in adding:
		if not diaTree.has(i):
			diaTree[i] = adding[i]
