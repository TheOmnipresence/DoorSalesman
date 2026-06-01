extends VBoxContainer

var item_res: Globals.Item = null

static var shop_texts = {}


func update_info() -> void:
	if item_res != null:
		if Globals.is_archipelago:
			$Name.text = "AP item"
			$Description.text = "Cool"
			if Globals.shop_inventory.has(item_res):
				var index = Globals.shop_inventory.find(item_res) + 1
				if shop_texts.has(index):
					$Name.text = shop_texts[index]
				else:
					if not is_inside_tree():
						return
					await get_tree().process_frame
					Archipelago.conn.scout(index, 2, set_ap_info)
		else:
			$Name.text = item_res.item_name
			$Description.text = item_res.description
			if item_res is Globals.Door:
				$Texture.texture = load("res://Sprites/" + item_res.item_name.to_snake_case() + ".png")
		
		visible = not Globals.items_collected_from_shop.has(item_res)
		$Buy.text = "Buy"
		$Price.text = str(item_res.cost)


func set_ap_info(item: NetworkItem) -> void:
	$Name.text = Archipelago.conn.get_player_name(item.dest_player_id) + "'s " + item.get_name()
	shop_texts[Globals.shop_inventory.find(item_res) + 1] = $Name.text


func _on_buy_pressed() -> void:
	if item_res != null:
		if Globals.money >= item_res.cost:
			#print("bought " + item_res.item_name)
			Globals.items_collected_from_shop.append(item_res)
			visible = false
			Globals.buy(item_res)
			await get_tree().process_frame
			update_info()
