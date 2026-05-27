extends Sprite2D


func _ready() -> void:
	await get_tree().process_frame
	var neighborhood = str(get_parent().get_parent().get_parent().name).to_snake_case()
	if not Globals.houses.has(neighborhood):
		Globals.houses[neighborhood] = {}
	if not Globals.houses[neighborhood].has(str(name)):
		set_apperance()
	else:
		set_colors(Globals.houses[neighborhood][str(name)].primary_color, Globals.houses[neighborhood][str(name)].secondary_color)
		#material = material.duplicate_deep()
		#var colors = []
		#colors.append(Color.WHITE) #stairs
		#colors.append(Globals.houses[neighborhood][str(name)].primary_color)
		#colors.append(darken(Globals.houses[neighborhood][str(name)].primary_color, 0.2))
		#colors.append(darken(Globals.houses[neighborhood][str(name)].secondary_color, -0.2))
		#colors.append(Color.BLACK)
		#colors.append(Globals.houses[neighborhood][str(name)].secondary_color)
		#material.set_shader_parameter("replace_colors", colors)
		
		get_child(0).texture = Globals.make_door_texture(Globals.houses[neighborhood][str(name)].door)


func set_apperance() -> void:
	material = material.duplicate_deep()
	var primary_color = Color.from_hsv(randf_range(0,1), 0.6, 0.5, 1)
	if randi_range(0,99) < roundi(get_parent().get_parent().get_parent().follow_palette_chance * 100):
		primary_color = get_parent().get_parent().get_parent().palette
	var secondary_color: Color
	if randi_range(0,99) < roundi(get_parent().get_parent().get_parent().oppose_palette_chance * 100):
		secondary_color = Color.WHITE - primary_color
		if get_parent().get_parent().get_parent().override_opposing_palette != Color.TRANSPARENT:
			secondary_color = get_parent().get_parent().get_parent().override_opposing_palette
	else:
		secondary_color = Color.from_hsv(primary_color.h + randf_range(-0.05,0.05), 0.4, 0.3, 1)
	var colors = []
	colors.append(Color.WHITE) #stairs
	colors.append(primary_color)
	colors.append(darken(primary_color, 0.2))
	colors.append(darken(secondary_color, -0.2))
	colors.append(Color.BLACK)
	colors.append(secondary_color)
	material.set_shader_parameter("replace_colors", colors)
	
	var door = get_parent().get_parent().get_parent().area_doors.pick_random().to_snake_case()
	get_child(0).texture = Globals.make_door_texture(door)
	
	var neighborhood = str(get_parent().get_parent().get_parent().name).to_snake_case()
	if not Globals.houses.has(neighborhood):
		Globals.houses[neighborhood] = {}
	Globals.houses[neighborhood][str(name)] = Globals.House.new(door, primary_color, secondary_color)


func color_from_range(min_val: float, max_val: float) -> Color:
	return Color(randf_range(min_val,max_val), randf_range(min_val,max_val), randf_range(min_val,max_val), 1)


func darken(color: Color, amount: float) -> Color:
	color.v -= amount
	return color


func set_colors(primary: Color, secondary: Color) -> void:
	if secondary == Color.TRANSPARENT:
		if randi_range(0,99) < roundi(get_parent().get_parent().get_parent().oppose_palette_chance * 100):
			secondary = Color.WHITE - primary
			if get_parent().get_parent().get_parent().override_opposing_palette != Color.TRANSPARENT:
				secondary = get_parent().get_parent().get_parent().override_opposing_palette
		else:
			secondary = Color.from_hsv(primary.h + randf_range(-0.05,0.05), 0.4, 0.3, 1)
	
	material = material.duplicate_deep()
	var colors = []
	colors.append(Color.WHITE) #stairs
	colors.append(primary)
	colors.append(darken(primary, 0.2))
	colors.append(darken(secondary, -0.2))
	colors.append(Color.BLACK)
	colors.append(secondary)
	material.set_shader_parameter("replace_colors", colors)
