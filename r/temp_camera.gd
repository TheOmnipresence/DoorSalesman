extends Camera2D


func _process(_delta: float) -> void:
	if Input.is_action_just_released("scroll_up"):
		zoom *= Vector2(1.1,1.1)
		update_pos()
	elif Input.is_action_just_released("scroll_down"):
		zoom /= Vector2(1.1,1.1)
		update_pos(-1)


func update_pos(mouse_muti := 1) -> void:
	offset = (get_global_mouse_position() * 0.2 * mouse_muti) + (offset * 0.8)
