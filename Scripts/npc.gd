## Any dialouge
class_name NPC extends StaticBody2D

## Is a dialouge tree. Runs "/" first, then continues along the path
@export var diaTree: Dictionary[String,Dialouge] = {}

@export var isPlaque = true

## Emits when any dialouge choice is made
signal any_button
## Holds the name of the dialouge choice made
var button_name = ""

@export var approved_doors: Array[String] = []

@export var current_door: String

@export var house: Sprite2D

@export var knock_power_required: int = 0

var old_door: String

@export var override_primary_color := Color.TRANSPARENT
@export var override_secondary_color := Color.TRANSPARENT


func _enter_tree() -> void:
	old_door = current_door


## Used in [method enterDialouge] to control the pressing of the choice buttons
func emit_buttons(button):
	button_name = button.key
	if approved_doors.has(button_name.capitalize()):
		button.action_condition.run()
		house.get_child(0).texture = Globals.make_door_texture(button_name)
		var neighborhood = str(get_parent().get_parent().get_parent().name).to_snake_case()
		if not Globals.houses.has(neighborhood):
			Globals.houses[neighborhood] = {}
		if Globals.houses[neighborhood].has(str(house.name)):
			Globals.houses[neighborhood][str(house.name)].door = button_name
	
	any_button.emit()


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
		
		if dialogue_tree[path].key == "knock":
			path += str(Globals.knock_power >= knock_power_required) + "/"
			continue
		elif dialogue_tree[path].key == "take_old":
			Globals.npc_data[str(name).to_snake_case()]["taken"] = true
			if Globals.is_archipelago:
				Globals.send_ap_item(str(name).capitalize() + " Old Door", Globals.ALL_NPCS.find(str(name).capitalize()) + 1000)
			else:
				Globals.warehouse_inventory.append(Globals.make_door_by_name(old_door))
			
			path += "take_old/"
			continue
		
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
		
		if dialogue_tree[path].options_doors:
			for i in dialogue_tree[path].options:
				if i.is_door:
					dialogue_tree[path].options.erase(i)
			for i in Globals.carry_inventory:
				var dialogue = Dialouge.new(i.item_name.to_snake_case(),i.item_name)
				dialogue.is_door = true
				dialogue.action_condition = DialougeActionTransition.new()
				dialogue.action_condition.toRun = "sell_" + i.item_name.to_snake_case()
				dialogue_tree[path].options.append(dialogue)
		
		if len(dialogue_tree[path].options) > 0:
			for i in dialogue_tree[path].options:
				var button := Button.new()
				button.custom_minimum_size.x = 100
				button.text = i.text
				button.name = i.key
				if i.action_condition != null:
					if i.action_condition.type == DialougeActionTransition.types.TRANSITION:
						button.disabled = not i.action_condition.run()
				button.pressed.connect(emit_buttons.bind(i))
				$Control/TextBox/ChoiceContainer.add_child(button)
			
			await any_button
			if get_door_check(dialogue_tree[path].options):
				if approved_doors.has(button_name.capitalize()):
					path += "good_door/"
				else:
					path += "bad_door/"
			else:
				path += button_name + "/"
			for i in $Control/TextBox/ChoiceContainer.get_children():
				i.queue_free()
		else:
			if dialogue_tree[path].set_dia_path != "":
				path = dialogue_tree[path].set_dia_path
			else:
				path += dialogue_tree[path].key + "/"
			if $Control/TextBox/Label.text != "":
				await get_tree().create_timer(1.5).timeout
	
	Globals.in_dialogue = false
	$Control/TextBox/Label.text = ""


func get_door_check(options: Array[Dialouge]) -> bool:
	for i in options:
		if i.key == button_name:
			return i.is_door
	return false
