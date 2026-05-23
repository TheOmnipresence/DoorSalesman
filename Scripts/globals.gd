extends Node


@onready var warehouse_inventory: Array[Door] = [get_door_by_name("Base Door")]
var truck_inventory: Array[Door] = []
var carry_inventory: Array[Door] = []

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
		Storage.new(1, "Carry", preload("res://Sprites/icon.svg"))
	],
}

var all_storage_names = map_dict(STORAGE_UPGRADES.duplicate(true), func(type): return type.map(func(e): return e.upgrade_name))

@warning_ignore("unused_signal")
signal update_doors

var all_doors: Array[Door] = [
	Door.new("Base Door", "Pretty boring door", 20, 45)
]

var npc_data := {}

var in_dialogue := false

var is_archipelago := false

var archipelago_locations_found: Array[String] = []


func _ready() -> void:
	Archipelago.connected.connect(connect_script)
	Archipelago.disconnected.connect((func(): is_archipelago = false))
	print(all_storage_names)


func connect_script() -> void:
	is_archipelago = true


func send_to_place(place_name: String) -> void:
	print("send to " + place_name)


func collect_item(item_name: String, called_from_archipelago := false) -> void:
	if merge_lists(all_storage_names.values()).has(item_name):
		if is_archipelago and not called_from_archipelago:
			send_ap_item(item_name, merge_lists(all_storage_names.values()).find(item_name))
		else:
			for i in all_storage_names:
				if all_storage_names[i].has(item_name):
					set(i + "_storage_level", 1 + get(i + "_storage_level"))


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
	pass


func get_door_by_name(door_name: String) -> Door:
	for i in all_doors:
		if i.door_name == door_name:
			return i
	return null


func merge_lists(lists: Array[Array]) -> Array:
	var result = []
	for i in lists:
		result.append_array(i)
	return result


func map_dict(dictionary: Dictionary, method: Callable) -> Dictionary:
	for i in dictionary:
		dictionary[i] = method.call(dictionary[i])
	return dictionary


class Storage extends Resource:
	var space: int
	
	var carry_sprite: Texture2D
	
	var upgrade_name: String
	
	func _init(space_amount := 0, u_name := "", carry_image := Texture2D.new()) -> void:
		space = space_amount
		carry_sprite = carry_image
		upgrade_name = u_name

class Door extends Resource:
	var door_name: String
	
	var description: String
	
	var cost: int
	
	var sell_for: int
	
	func _init(name_val: String, des: String, cost_val: int, price_val: int) -> void:
		door_name = name_val
		description = des
		cost = cost_val
		sell_for = price_val
