extends VBoxContainer


var door_res: Globals.Door = null


func _ready() -> void:
	update_info()


func update_info() -> void:
	if door_res != null:
		$Name.text = door_res.door_name
		$Description.text = door_res.description
		$Texture.texture = load("res://Sprites/base_door.png")
