extends Control


func _on_play_pressed() -> void:
	#await fade_in(1)
	#Globals.get_tree().scene_changed.connect(fade_in.bind(-1), CONNECT_ONE_SHOT)
	get_tree().change_scene_to_file("res://Scenes/warehouse.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()


func fade_in(dir: int) -> void:
	get_tree().current_scene.get_node("Fade").color.a = 0
	for i in range(50):
		get_tree().current_scene.get_node("Fade").color.a += 0.02 * dir
		await get_tree().process_frame
