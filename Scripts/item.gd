extends VBoxContainer

var item_res: Globals.Item = null


func update_info() -> void:
	if item_res != null:
		visible = not Globals.items_collected_from_shop.has(item_res)
		$Name.text = item_res.item_name
		$Description.text = item_res.description
		$Buy.text = "Buy"
		$Price.text = str(item_res.cost)
		if item_res is Globals.Door:
			$Texture.texture = load("res://Sprites/" + item_res.item_name.to_snake_case() + ".png")


func _on_buy_pressed() -> void:
	if item_res != null:
		print("bought " + item_res.item_name)
		Globals.items_collected_from_shop.append(item_res)
		visible = false
		Globals.buy(item_res)
		await get_tree().process_frame
		update_info()
