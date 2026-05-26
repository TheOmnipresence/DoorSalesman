extends Control


@export var slide_index: int = 0:
	set(value):
		if value >= 0 and value < len($Slides.get_children()):
			slide_index = value
			
			for i in $Slides.get_children():
				i.hide()
			
			$Slides.get_child(value).show()

@export var area_doors: Array[String]

@export_range(0,1) var follow_palette_chance: float = 0.25

@export var palette: Color


func _ready() -> void:
	get_node("Right").pressed.connect(func(): slide_index += 1)
	get_node("Left").pressed.connect(func(): slide_index -= 1)
