## Dialouge that causes an action to happen or dialouge that transitions onto others depending on variable values.
class_name DialougeActionTransition extends Resource

enum types {ACTION, TRANSITION}

## The type of action/reaction, uses [enum Globals.types]
@export var type: types = types.ACTION

## The action to run or the variable to get
@export var toRun: String

## The operator to use when comparing [member toRun] to [member targetVal] (only used when [member type] is transition).
@export var operator: Variant.Operator = OP_MAX

## The value that [member toRun] is compared to when [member type] is transition. Compared using [member operator].
@export var targetVal: Variant

## Wether to not the value given from comparing the value.
@export var notValue := false


func _init(type_val := types.ACTION, run_val := "", operator_val := OP_MAX, target_val: Variant = "") -> void:
	type = type_val
	toRun = run_val
	operator = operator_val
	targetVal = target_val


## Runs actions (things that effect the world and player) and transitions (pushes the dialouge on depending on the world and player).
func run() -> Variant:
	if type == types.ACTION:
		match toRun:
			# Add new actions here
			var x when x.left(4) == "recieve_":
				Globals.money_amount += int(toRun.right(-8))
			var x when x.left(5) == "remove_":
				Globals.money_amount -= int(toRun.right(-7))
			#var x when x.left(8) == "reforge_":
				#for i in Globals.allReforges:
					#if Globals.allReforges[i].has(x.right(-8).to_camel_case()) and not Globals.availibleReforges[i].has(x.right(-8).to_camel_case()):
						#Globals.availibleReforges[i].append(x.right(-8).to_camel_case())
			var x when x.left(5) == "send_":
				Globals.send_to_place(x.right(-5))
		
		return null
	else:
		return getValue()


func getValue() -> Variant:
	# Add new classes here
	var classes = {"Globals":Globals,"Player":Globals.playerRef,"Camera":Globals.cameraRef,"Data":Globals.npcData}
	
	var splitText = toRun.split(".")
	var value = classes[splitText[0]]
	splitText.remove_at(0)
	for i in splitText:
		if i in value:
			value = value[i]
	
	var result = comparevals(value,targetVal,operator)
	if notValue:
		return not result
	else:
		return result


## Compares the values using the operator [param op]. Only returns boolean values when comparing, else just [param val1]. Because of this, only uses boolean-returning operators. Any other operator will lead to returning the original value.
func comparevals(val1, val2, op: Variant.Operator) -> Variant:
	match op:
		OP_EQUAL:
			if typeof(val1) == typeof(val2):
				return val1 == val2
			return false
		OP_NOT_EQUAL:
			return val1 != val2
		OP_LESS:
			return val1 < val2
		OP_LESS_EQUAL:
			return val1 <= val2
		OP_GREATER:
			return val1 > val2
		OP_GREATER_EQUAL:
			return val1 >= val2
		OP_AND:
			return val1 and val2
		OP_OR:
			return val1 or val2
		OP_XOR:
			return bool(val1) != bool(val2)
		OP_NOT:
			return not val1
		OP_IN:
			return val2 in val1
		_:
			return val1
