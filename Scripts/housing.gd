extends Control


var slide_index: int = 2

func _ready() -> void:
	get_node("Right").pressed.connect(func(): slide_index += 1)
	get_node("Left").pressed.connect(func(): slide_index -= 1)
