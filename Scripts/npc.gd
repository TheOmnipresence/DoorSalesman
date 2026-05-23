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


## Starts the dialouge
func enter_dialouge():
	run_dialogue(diaTree)


## Runs the [param dialogue_tree]
func run_dialogue(dialogue_tree: Dictionary[String,Dialouge]) -> void:
	$Control/TextBox/Label.text = ""
	var path = "/"
	
	while true:
		if not dialogue_tree.has(path): break
		
		#if not dialogue_tree[path].options.is_empty():
			#dialogue_tree[path].testOptions()
		
		if dialogue_tree[path].action_condition != null:
			var runVal = dialogue_tree[path].action_condition.run()
			if runVal != null:
				if not dialogue_tree.has(path + str(runVal) + "/"):
					path += "else/"
				else:
					path += str(runVal) + "/"
				continue
		
		$Control/TextBox/Label.text = dialogue_tree[path].text
		
		if dialogue_tree[path].active_speaker != ^"":
			get_node(dialogue_tree[path].active_speaker).expression = dialogue_tree[path].expression
		
		if len(dialogue_tree[path].options) > 0:
			for i in dialogue_tree[path].options:
				var button := Button.new()
				button.custom_minimum_size.x = 100
				button.text = i.text
				button.name = i.key
				if i.action_condition != null:
					if i.action_condition.type == DialougeActionTransition.types.TRANSITION:
						button.disabled = not i.action_condition.run()
				button.pressed.connect(func():emitButtons(button.name))
				$Control/TextBox/ChoiceContainer.add_child(button)
			
			await anybutton
			path += nameOfButton + "/"
			for i in $Control/TextBox/ChoiceContainer.get_children():
				i.queue_free()
		else:
			path += dialogue_tree[path].key + "/"
			if $Control/TextBox/Label.text != "":
				await get_tree().create_timer(3).timeout
	
	Globals.in_dialogue = false
	$Control/TextBox/Label.visible = false
