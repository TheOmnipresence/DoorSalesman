extends Node


var hours: int = 12:
	set(value):
		hours = value
		if hours > 24:
			hours -= 24
			days += 1
var days: int:
	set(value):
		days = value
		
		for neighborhood in houses:
			if not visited.has(neighborhood):
				continue
			for house in houses[neighborhood]:
				var current_house = houses[neighborhood][house]
				
				if randi_range(0,99) < make_door_by_name(current_house.door).breakability and (not (current_house.door == "ice_door" and neighborhood == "coldington") or randi_range(0,3) == 0):
					var possible_replacements = []
					for i in all_doors:
						if i.repair_to_door == current_house.door.capitalize():
							possible_replacements.append(i)
					
					if not possible_replacements.is_empty():
						current_house.door = possible_replacements.pick_random().item_name.to_snake_case()
						if npc_data.has(current_house.npc):
							npc_data[current_house.npc]["given"] = false
							npc_data[current_house.npc]["taken"] = false

var current_space := "warehouse"
var visited := ["warehouse"]
var availible_spaces := ["warehouse", "shrimpville", "fancytown"]
const ALL_SPACES = ["warehouse", "shrimpville", "fancytown", "mansion_lane", "coldington", "industrial_zone"]
var houses: Dictionary[String, Dictionary] = {}

@onready var warehouse_inventory: Array[Door] = [make_door_by_name("Base Door"), make_door_by_name("Base Door"), make_door_by_name("Scratched Door")]
var truck_inventory: Array[Door] = []
var carry_inventory: Array[Door] = []

var upgrades: Array[Upgrade] = []

var warehouse_storage_level = 0
var truck_storage_level = 0
var carry_storage_level = 0

var STORAGE_UPGRADES = {
	"warehouse": [
		Storage.new(9, "Warehouse Storage 1"),
		Storage.new(18, "Warehouse Storage 2", "More doors in the warehouse", "industrial_zone", 400)
	],
	"truck": [
		Storage.new(2, "Car Trunk"),
		#Storage.new(8, "Truck Bed", "Bring more doors!", "")
	],
	"carry": [
		Storage.new(1, "Carry"),
		Storage.new(3, "Wheelbarrow", "Fit more doors!", "mansion_lane", 30),
	],
}

var all_storage_names = map_dict(STORAGE_UPGRADES.duplicate(true), func(type): return type.map(func(e): return e.item_name))

@warning_ignore("unused_signal")
signal update_doors
@warning_ignore("unused_signal")
signal update_brought_doors

var all_doors: Array[Door] = [
	Door.new("Base Door", "Pretty boring door", 20, 45),
	Door.new("Knobless Base Door", "Can't open :(", 10, 35, 5, "Base Door"),
	Door.new("Plain Door", "A very boring door", 25, 55),
	Door.new("Scratched Door", "A bit beat up", 10, 30, 5, "Plain Door"),
	Door.new("Oak Door", "Kinda fancy", 60, 100),
	Door.new("Cracked Oak Door", "Little less fancy", 45, 75, 10, "Oak Door"),
	Door.new("Hole Oak Door", "oof", 35, 40, 20, "Oak Door"),
	Door.new("Ripped Screen Door", "In peices", 10, 5, 10, "Screen Door"),
	Door.new("Screen Door", "See-through", 25, 55),
	Door.new("Ewhs Door", "elliptical window handle star door", 90, 115),
	Door.new("Fractured Ewhs Door", "fractured elliptical window handle star door", 70, 90, 15, "Ewhs Door", ["Glassworking"]),
	Door.new("Blue Door", "It's blue", 80, 90),
	Door.new("Rough Blue Door", "It's a rough blue", 65, 70, 10, "Blue Door"),
	Door.new("Gold Oak Door", "Shiny", 190, 250),
	Door.new("Glass Door", "It's you!", 110, 130),
	Door.new("Fractured Glass Door", "Is it?", 40, 40, 40, "Glass Door", ["Glassworking"]),
	Door.new("Mansion Door", "Suprisingly simple", 80, 110),
	Door.new("Cracked Mansion Door", "Slightly broken", 60, 85, 15, "Mansion Door"),
	Door.new("Steel Door", "Big wheel", 600, 750),
	Door.new("Wheelless Steel Door", "Aw no wheel", 540, 600, 30, "Steel Door", ["Welding"]),
	Door.new("Ice Door", "Very cold", 210, 235, -1, "", [], 100),
	Door.new("Melted Door", "It's dripping", 130, 135, 5, "Ice Door", ["Freezer"]),
	Door.new("Brick Door", "Solid", 140, 165),
]
@onready var doors_in_shop: Array[Door] = [
	make_door_by_name("Base Door"),
	make_door_by_name("Base Door"),
	make_door_by_name("Oak Door", "fancytown"),
	make_door_by_name("Gold Oak Door", "fancytown"),
	make_door_by_name("Ewhs Door", "shrimpville"),
	make_door_by_name("Ice Door", "shrimpville"),
	make_door_by_name("Glass Door", "mansion_lane"),
	make_door_by_name("Wheelless Steel Door", "industrial_zone"),
]
var all_upgrades: Array[Upgrade] = [
	Upgrade.new("Double Cash", "Doubles earned money", 45, "warehouse", 2),
	Upgrade.new("Toolkit", "Basic repairing", 15, "shrimpville"),
	Upgrade.new("Glassworking", "Repair glass", 45, "mansion_lane"),
	Upgrade.new("Welding", "Repair metal", 50, "industrial_zone"),
	Upgrade.new("Freezer", "Make things cold", 190, "industrial_zone")
]

@onready var shop_inventory: Array = sort_by_shipment(all_upgrades + doors_in_shop + get_shop_storage())

@onready var items_collected_from_shop: Array[Item] = [
	STORAGE_UPGRADES["warehouse"][0],
	STORAGE_UPGRADES["truck"][0],
	STORAGE_UPGRADES["carry"][0],
]

var npc_data := {
	"john_bottom":{
		"given": true,
		"taken": true
	}
}

var in_dialogue := false

var money: int = 0:
	set(value):
		money = value
		if value > 0:
			got_money = true

var got_money := false

const WORKSHOP_TOOLS = [
	"Toolkit",
	"Glassworking",
	"Welding",
	"Freezer",
]

var tools: Array[String] = []

var knock_power := 0

const ALL_NPCS = [
	"May",
	"Doug",
	"Mr Brown",
	"Liliana",
	"Ice Man",
	
	"Poshman",
	"Hole Guy",
	"Gold",
	
	"John Bottom",
	"John Top",
	
	"Dr Lebut",
]

var is_archipelago := false

var archipelago_locations_found: Array[String] = []

var ap_items_recieved: Array[NetworkItem] = []

var deathlink_amnesty: int = 0

const DEATHLINK_MESSAGES = [
	"%s went bankrupt",
	"%s didn't sell enough doors",
	"%s's rent was due",
]


func _ready() -> void:
	Archipelago.connected.connect(connect_script)
	Archipelago.disconnected.connect((func(): is_archipelago = false))


## The connection script for archipelago
func connect_script(_conn: ConnectionInfo, _json: Dictionary) -> void:
	is_archipelago = true
	got_money = true
	Archipelago.conn.deathlink.connect(go_bankrupt.bind(true))
	Archipelago.set_deathlink(is_equal_approx(Archipelago.conn.slot_data["death_link"], 1.0))
	Archipelago.conn.obtained_item.connect(get_ap_item)
	Archipelago.conn.force_scout_all()
	warehouse_inventory = []
	#get_tree().current_scene.update_all()


func go_bankrupt(from_deathlink := false, source := "", cause := "", _json := {}) -> void:
	npc_data = {}
	houses = {}
	money = 0
	got_money = false
	hours = 12
	days = 0
	if is_archipelago:
		knock_power = 0
		warehouse_storage_level = 0
		warehouse_inventory = []
		truck_storage_level = 0
		truck_inventory = []
		carry_storage_level = 0
		carry_inventory = []
		tools = []
		upgrades = []
		availible_spaces = ["warehouse", "shrimpville", "fancytown"]
	else:
		warehouse_inventory = [make_door_by_name("Base Door"), make_door_by_name("Base Door"), make_door_by_name("Scratched Door")]
		var remove_items = []
		for i in items_collected_from_shop:
			if i is Door:
				remove_items.append(i)
		for i in remove_items:
			items_collected_from_shop.erase(i)
	
	await send_to_place("warehouse")
	
	if is_archipelago:
		for i in ap_items_recieved:
			get_ap_item(i, false)
		
		if not from_deathlink:
			send_deathlink()
		else:
			trigger_popup("Death from %s: %s" % [source, cause], Color.FIREBRICK)


## Sends the deathlink packet, accounting for amnesty
func send_deathlink() -> void:
	deathlink_amnesty += 1
	if deathlink_amnesty >= Archipelago.conn.slot_data["death_link_amnesty"]:
		deathlink_amnesty = 0
		var death_cause = DEATHLINK_MESSAGES.pick_random() % Archipelago.conn.get_player().get_name()
		Archipelago.conn.send_deathlink(death_cause)


## Sends the Archipelago goal signal
func finish_archipelago() -> void:
	Archipelago.set_client_status(AP.ClientStatus.CLIENT_GOAL)
	
	if not Globals.finished_archipelago:
		trigger_popup("Finished Archipelago", Color.DARK_GOLDENROD)
		Globals.finished_archipelago = true


func get_ap_item(item: NetworkItem, add_to_recieved := true) -> void:
	var item_name = item.get_name()
	
	if not ap_items_recieved.has(item) and add_to_recieved:
		ap_items_recieved.append(item)
	
	await get_tree().process_frame
	#if item_name == "0":
		#await get_tree().process_frame
		#item_name = "Base Door"
	
	if item_name == "Day Advance":
		hours += 24
	elif all_doors.map(func(e): return e.item_name).has(item_name):
		collect_item(item_name, make_door_by_name(item_name), true)
	elif WORKSHOP_TOOLS.has(item_name):
		var upgrade = null
		for i in all_upgrades:
			if i.item_name == item_name:
				upgrade = i
				break
		if upgrade != null:
			collect_item(item_name, upgrade, true)
		else:
			collect_item(item_name, Upgrade.new(item_name, "Item collected from archipelago"), true)
	elif item_name.contains(" neighborhood unlock"):
		availible_spaces.append(item_name.get_slice(" neighborhood unlock",0).to_snake_case())
	elif item_name.contains("Knock Power "):
		knock_power += 1
	else:
		for i in all_storage_names:
			if all_storage_names[i].has(item_name):
				set(i + "_storage_level", 1 + get(i + "_storage_level"))
				break
	
	trigger_popup("Item: " + item_name + " from " + Archipelago.conn.get_player_name(item.src_player_id), Color.GREEN)


func sort_by_shipment(list: Array) -> Array:
	var result = []
	var current_shipment = "warehouse"
	while result.size() < list.size():
		for i: Item in list:
			if not result.has(i):
				if i.shipment == current_shipment:
					result.append(i)
		if current_shipment == ALL_SPACES[-1]:
			break
		current_shipment = ALL_SPACES[ALL_SPACES.find(current_shipment) + 1]
	return result


func sell(door: Door):
	var sell_multi = 1
	for i in upgrades:
		sell_multi = sell_multi * i.sell_multiplier
	money += door.sell_for * sell_multi
	carry_inventory.erase(door)
	truck_inventory.erase(door)
	warehouse_inventory.erase(door)
	get_tree().current_scene.update_all()


func buy(item: Item):
	money -= item.cost
	collect_item(item.item_name, item)


func unlock_place(place_name: String) -> void:
	availible_spaces.append(place_name)
	get_tree().current_scene.update_map()


func send_to_place(place_name: String) -> void:
	if not visited.has(place_name): visited.append(place_name)
	current_space = place_name
	
	for i in range(50):
		get_tree().current_scene.get_node("Fade").color.a += 0.02
		await get_tree().process_frame
	
	hours += 6
	
	var scene_parent = get_tree().current_scene.get_child(0).get_node("Tabs/View")
	scene_parent.get_child(0).queue_free()
	if place_name != "warehouse":
		var place_node = load("res://Scenes/" + place_name + ".tscn").instantiate()
		get_tree().process_frame.connect(func(): place_node.name = place_name.to_pascal_case(), CONNECT_ONE_SHOT)
		scene_parent.add_child(place_node)
	else:
		scene_parent.add_child(Node.new())
	get_tree().current_scene.update_all()
	
	for i in range(50):
		get_tree().current_scene.get_node("Fade").color.a -= 0.02
		await get_tree().process_frame
	
	in_dialogue = false
	
	print("send to " + place_name)


func collect_item(item_name: String, shop_item: Item = null, called_from_archipelago := false) -> void:
	if shop_item is Door:#all_doors.map(func(e): return e.item_name).has(item_name) or shop_item is Door:
		if is_archipelago and not called_from_archipelago:
			send_shop_ap(shop_item)
		else:
			warehouse_inventory.append(make_door_by_name(item_name))
	elif shop_item is Upgrade:
		if is_archipelago and not called_from_archipelago:
			send_shop_ap(shop_item)
		else:
			upgrades.append(shop_item)
			if WORKSHOP_TOOLS.has(item_name):
				tools.append(item_name)
			if item_name.left(12) == "Knock Power ":
				knock_power += 1
			if tools.has("Toolkit") and tools.has("Glassworking"):
				if not Globals.availible_spaces.has("industrial_zone"):
					Globals.availible_spaces.append("industrial_zone")
	elif shop_item is Storage:#merge_lists(all_storage_names.values()).has(item_name) or shop_item is Storage:
		if is_archipelago and not called_from_archipelago:
			send_shop_ap(shop_item) #merge_lists(all_storage_names.values()).find(item_name) + 1000)
		else:
			for i in all_storage_names:
				if all_storage_names[i].has(item_name):
					set(i + "_storage_level", 1 + get(i + "_storage_level"))
					break
	
	get_tree().current_scene.update_all()


func send_shop_ap(item: Item) -> void:
	send_ap_item(item.item_name, shop_inventory.find(item) + 1)


func send_ap_item(loc_name: String, loc_id: int) -> void:
	if not archipelago_locations_found.has(loc_name):
		#print("Outgoing location: ", id)
		Archipelago.collect_location(loc_id)
		Archipelago.conn.scout(loc_id,0,archipelago_popup)


func archipelago_popup(info: NetworkItem) -> void:
	var playerName = Archipelago.conn.get_player_name(info.dest_player_id)
	var itemName = info.get_name()
	trigger_popup("Archipelago Item: " + playerName + "'s " + itemName, Color.GOLDENROD)


func trigger_popup(text: String, color: Color):
	print_rich("[color=" + color.to_html(false) + "]" + text + "[/color]")
	var panel = PanelContainer.new()
	var label = Label.new()
	label.label_settings = LabelSettings.new()
	label.label_settings.font_color = color
	label.text = text
	panel.add_child(label)
	get_tree().current_scene.get_node("PopupContainer").add_child(panel)
	await get_tree().create_timer(5).timeout
	if is_instance_valid(panel):
		panel.queue_free()


func make_door_texture(door_name: String) -> Texture2D:
	return load("res://Sprites/" + door_name.to_snake_case() + ".png")


func make_door_by_name(item_name: String, shipment: String = "warehouse") -> Door:
	item_name = item_name.capitalize()
	for i in all_doors:
		if i.item_name == item_name:
			var result = Door.new(i.item_name, i.description, i.cost, i.sell_for, i.repair_cost, i.repair_to_door, i.equipment_needed)
			result.shipment = shipment
			return result
	print(item_name, " is null")
	return null


func get_upgrade_by_name(item_name: String) -> Upgrade:
	for i in all_doors:
		if i.item_name == item_name:
			return Upgrade.new(i.item_name, i.description, i.cost, i.sell_multi)
	return null


func merge_lists(lists: Array) -> Array:
	var result = []
	for i in lists:
		result.append_array(i)
	return result


func get_shop_storage() -> Array:
	var result = []
	for type in STORAGE_UPGRADES:
		var reversed = range(STORAGE_UPGRADES[type].size())
		reversed.reverse()
		for i in reversed:
			result.append(STORAGE_UPGRADES[type][i])
		result.remove_at(-1)
	return result


func map_dict(dictionary: Dictionary, method: Callable) -> Dictionary:
	for i in dictionary:
		dictionary[i] = method.call(dictionary[i])
	return dictionary


func array_has_all(array: Array, all: Array) -> bool:
	for i in all:
		if not array.has(i):
			return false
	return true


#func ascending_groups(list: Array) -> Array[Array]:
	#var result: Array[Array] = []
	#for i in range(list.size()):
		#if i == 0:
			#result.append([list[i]])
		#elif result[-1] == [0] or result[-1][-1] != list[i] - 1:
			#result.append([list[i]])
		#else:
			#result[-1].append(list[i])
	#return result


class Item extends Resource:
	var item_name: String
	
	var description: String
	
	var shipment: String
	
	var cost: int


class Storage extends Item:
	var space: int
	
	func _init(space_amount := 0, u_name := "", description_val := "", neighborhood := "", cost_val := 0) -> void:
		space = space_amount
		item_name = u_name
		description = description_val
		shipment = neighborhood
		cost = cost_val


class Door extends Item:
	var sell_for: int
	
	var repair_cost: int
	
	var repair_to_door: String
	
	var equipment_needed: Array[String]
	
	var breakability: int = 25
	
	
	func _init(name_val := "", des := "", cost_val := 0, price_val := 0, repair_val := -1, repair_to := "", repair_tools: Array[String] = [], break_chance := 25) -> void:
		item_name = name_val
		description = des
		cost = cost_val
		sell_for = price_val
		repair_cost = repair_val
		repair_to_door = repair_to
		equipment_needed = repair_tools
		breakability = break_chance


class Upgrade extends Item:
	var sell_multiplier: int
	
	func _init(name_val := "", des := "", cost_val := 0, neighborhood := "", sell_m := 1) -> void:
		item_name = name_val
		description = des
		cost = cost_val
		sell_multiplier = sell_m
		shipment = neighborhood


class House extends Resource:
	var door: String
	
	var primary_color: Color
	var secondary_color: Color
	
	var npc: String
	
	func _init(door_name := "", primary := Color.WHITE, secondary := Color.BLACK, npc_val := "") -> void:
		door = door_name
		primary_color = primary
		secondary_color = secondary
		npc = npc_val
