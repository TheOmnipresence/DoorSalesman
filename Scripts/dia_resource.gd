## Dialouge used in conversations.
class_name Dialouge extends Resource


## The reference of this dialouge in the dialouge tree
@export var key: String

## The text to say during this dialouge
@export var text: String

## The active speaker, as a [NodePath], node should be a [Sprite2D].
@export var active_speaker: NodePath

## The expression of the [member active_speaker]. Used to set it's texture value.
@export var expression: String

## The options availible to answer this dialouge. The [member key] will not be used if there are any options here, instead using the keys of the answers. This variable will not be used when this is an option in another dialouge.
@export var options: Array[Dialouge]

## The action or condition that this dialouge uses, is a [DialougeActionTransition]. This variable will be used to check if the option is valid when this is an option in another dialouge.
@export var action_condition := DialougeActionTransition.new(DialougeActionTransition.types.ACTION,"")

@export var options_doors := false

@export var is_door := false

@export var set_dia_path := ""


func _init(key_val := "", text_val := "", options_val: Array[Dialouge] = [], action_condition_val := DialougeActionTransition.new(DialougeActionTransition.types.ACTION, ""), to_path := "", doors_as_options := false, is_a_door := false) -> void:
	key = key_val
	text = text_val
	options = options_val
	action_condition = action_condition_val
	set_dia_path = to_path
	options_doors = doors_as_options
	is_door = is_a_door


func testOptions() -> void:
	var toErase = []
	for option in options:
		if option.action_condition.toRun != "":
			if not option.action_condition.getValue():
				toErase.append(option)
	for option in toErase:
		options.erase(option)


static func new_from_dict(values: Dictionary[String,Variant]) -> Dialouge:
	var result := Dialouge.new()
	for i in values:
		if i in result:
			result.set(i, values[i])
	return result
