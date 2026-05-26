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
	house.get_child(0).texture = Globals.make_door_texture(current_door)


func _process(_delta: float) -> void:
	if mouse_hovering and Input.is_action_just_pressed("mouse1") and not Globals.in_dialogue:
		Globals.in_dialogue = true
		enter_dialouge()
