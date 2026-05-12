extends CanvasLayer
@onready var btn_axe: Button = $Panel/MarginContainer/HBoxContainer/Btn_Axe

signal tool_selected(tool)

func _on_btn_axe_pressed() -> void:
	tool_selected.emit("axe")

func _on_btn_hoe_pressed() -> void:
	tool_selected.emit("hoe")

func _on_btn_wathering_pressed() -> void:
	tool_selected.emit("wathering")

func _on_btn_pumpkin_pressed() -> void:
	tool_selected.emit("pumpkin")
