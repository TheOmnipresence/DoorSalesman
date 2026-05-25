extends Sprite2D



func _ready() -> void:
	material = material.duplicate_deep()
	var primary_color = Color.from_hsv(randf_range(0,1), 0.6, 0.5, 1)
	var secondary_color: Color
	if randi_range(0,1) == 1:
		secondary_color = Color.WHITE - primary_color
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
	
	var door = get_parent().get_parent().get_parent().area_doors.pick_random()
	get_child(0).texture = Globals.make_door_texture(door)


func color_from_range(min_val: float, max_val: float) -> Color:
	return Color(randf_range(min_val,max_val), randf_range(min_val,max_val), randf_range(min_val,max_val), 1)


func darken(color: Color, amount: float) -> Color:
	color.v -= amount
	return color
