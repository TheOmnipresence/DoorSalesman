## Any dialouge
class_name NPC extends StaticBody2D

## Is a dialouge tree. Runs "/" first, then continues along the path
@export var diaTree: Dictionary[String,Dialouge] = {}

@export var isPlaque = true

## Emits when any dialouge choice is made
signal anybutton
## Holds the name of the dialouge choice made
var nameOfButton = ""


## Used in [method enterDialouge] to control the pressing of the choice buttons
func emitButtons(buttonName):
	nameOfButton = buttonName
	anybutton.emit()


## Starts the dialouge, called from the player.
func enter_dialouge():
	$Control/TextBox/Label.text = ""
	var path = "/"
	
	while true:
		if not diaTree.has(path): break
		
		if not diaTree[path].options.is_empty():
			diaTree[path].testOptions()
		
		if diaTree[path].action_condition != null:
			var runVal = diaTree[path].action_condition.run()
			if runVal != null:
				if not diaTree.has(path + str(runVal) + "/"):
					path += "else/"
				else:
					path += str(runVal) + "/"
				continue
		
		$Control/TextBox/Label.text = diaTree[path].text
		
		if diaTree[path].active_speaker != ^"":
			get_node(diaTree[path].active_speaker).expression = diaTree[path].expression
		
		if len(diaTree[path].options) > 0:
			for i in diaTree[path].options:
				var button := Button.new()
				button.custom_minimum_size.x = 100
				button.text = i.text
				button.name = i.key
				button.pressed.connect(func():emitButtons(button.name))
				$Control/TextBox/ChoiceContainer.add_child(button)
			
			await anybutton
			path += nameOfButton + "/"
			for i in $Control/TextBox/ChoiceContainer.get_children():
				i.queue_free()
		else:
			path += diaTree[path].key + "/"
			if $Control/TextBox/Label.text != "":
				await get_tree().create_timer(3).timeout
	
	Globals.in_dialouge = false
	$Control/TextBox/Label.visible = false
