extends VBoxContainer

var item_res: Globals.Item = null

func update_info() -> void:
	if item_res != null:
		$Name.text = item_res.item_name
		$Description.text = item_res.description
		$Buy.text = "Buy"
		$Price.text = str(item_res.cost)
		if item_res is Globals.Door:
			$Texture.texture = load("res://Sprites/" + item_res.item_name.to_snake_case() + ".png")


func _on_buy_pressed() -> void:
	if item_res != null:
		Globals.buy(item_res)
