extends CanvasLayer

@onready var label: Label = $MarginContainer/HBoxContainer/Label

func eat_fruit():
	var num_fruits = int(label.text)
	label.text = str(num_fruits + 1)
	
