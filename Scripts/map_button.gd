extends Button


@export var connections: Array[Button]


func _ready() -> void:
	pressed.connect(Globals.send_to_place.bind(str(name).to_snake_case()))
