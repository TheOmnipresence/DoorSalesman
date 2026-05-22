extends Node


var npc_data := {}

var in_dialogue := false

var is_archipelago := false

var archipelago_locations_found: Array[String] = []


func _ready() -> void:
	Archipelago.connected.connect(connect_script)
	Archipelago.disconnected.connect((func(): is_archipelago = false))


func connect_script() -> void:
	is_archipelago = true


func send_to_place(place_name: String) -> void:
	print("send to " + place_name)


func collect_item(item_name: String, called_from_archipelago := false) -> void:
	pass


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
