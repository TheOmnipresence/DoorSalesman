extends Node


var current_space := "warehouse"
var visited := ["warehouse"]
var availible_spaces := ["warehouse", "shrimpville", "fancytown"]
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
		Storage.new(9, "Warehouse Storage 1")
	],
	"truck": [
		Storage.new(2, "Truck Bed")
	],
	"carry": [
		Storage.new(1, "Carry")
	],
}

var all_storage_names = map_dict(STORAGE_UPGRADES.duplicate(true), func(type): return type.map(func(e): return e.item_name))

@warning_ignore("unused_signal")
signal update_doors
@warning_ignore("unused_signal")
signal update_brought_doors

var all_doors: Array[Door] = [
	Door.new("Base Door", "Pretty boring door", 20, 45),
	Door.new("Scratched Door", "A bit beat up", 10, 30),
	Door.new("Oak Door", "Kinda fancy", 60, 100),
	Door.new("Ripped Door", "In peices", 10, 5),
]
@onready var doors_in_shop: Array[Door] = [
	make_door_by_name("Base Door"),
	make_door_by_name("Base Door"),
	make_door_by_name("Oak Door", "fancytown"),
]
var all_upgrades: Array[Upgrade] = [
	Upgrade.new("Double Cash", "Doubles earned money", 45, "warehouse", 2)
]

@onready var shop_inventory: Array = all_upgrades + doors_in_shop + get_shop_storage()

@onready var items_collected_from_shop: Array[Item] = [
	STORAGE_UPGRADES["warehouse"][0],
	STORAGE_UPGRADES["truck"][0],
	STORAGE_UPGRADES["carry"][0],
]

var npc_data := {
	"may":{
		"given": false
	},
	"mr_brown":{
		"given": false
	},
}

var in_dialogue := false

var money: int = 0:
	set(value):
		money = value
		if value > 0:
			got_money = true

var got_money := false

var is_archipelago := false

var archipelago_locations_found: Array[String] = []


func _ready() -> void:
	Archipelago.connected.connect(connect_script)
	Archipelago.disconnected.connect((func(): is_archipelago = false))


func connect_script() -> void:
	is_archipelago = true
	got_money = true


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
	collect_item(item.item_name)


func unlock_place(place_name: String) -> void:
	availible_spaces.append(place_name)
	get_tree().current_scene.update_map()


func send_to_place(place_name: String) -> void:
	if not visited.has(place_name): visited.append(place_name)
	current_space = place_name
	
	for i in range(100):
		get_tree().current_scene.get_node("Fade").color.a += 0.01
		await get_tree().process_frame
	
	var scene_parent = get_tree().current_scene.get_child(0).get_node("Tabs/View")
	scene_parent.get_child(0).queue_free()
	if place_name != "warehouse":
		var place_node = load("res://Scenes/" + place_name + ".tscn").instantiate()
		get_tree().process_frame.connect(func(): place_node.name = place_name.to_pascal_case(), CONNECT_ONE_SHOT)
		scene_parent.add_child(place_node)
	else:
		scene_parent.add_child(Node.new())
	get_tree().current_scene.update_all()
	
	for i in range(100):
		get_tree().current_scene.get_node("Fade").color.a -= 0.01
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
	elif shop_item is Storage:#merge_lists(all_storage_names.values()).has(item_name) or shop_item is Storage:
		if is_archipelago and not called_from_archipelago:
			send_shop_ap(shop_item) #merge_lists(all_storage_names.values()).find(item_name) + 1000)
		else:
			for i in all_storage_names:
				if all_storage_names[i].has(item_name):
					set(i + "_storage_level", 1 + get(i + "_storage_level"))


func send_shop_ap(item: Item) -> void:
	send_ap_item(item.item_name, shop_inventory.find(item))


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
	# actually popup here TODO


func make_door_texture(door_name: String) -> Texture2D:
	return load("res://Sprites/" + door_name.to_snake_case() + ".png")


func make_door_by_name(item_name: String, shipment: String = "warehouse") -> Door:
	for i in all_doors:
		if i.item_name == item_name:
			var result = Door.new(i.item_name, i.description, i.cost, i.sell_for)
			result.shipment = shipment
			return result
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
	
	func _init(space_amount := 0, u_name := "", neighborhood := "") -> void:
		space = space_amount
		item_name = u_name
		shipment = neighborhood


class Door extends Item:
	var sell_for: int
	
	func _init(name_val := "", des := "", cost_val := 0, price_val := 0) -> void:
		item_name = name_val
		description = des
		cost = cost_val
		sell_for = price_val


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
	
	func _init(door_name := "", primary := Color.WHITE, secondary := Color.BLACK) -> void:
		door = door_name
		primary_color = primary
		secondary_color = secondary
