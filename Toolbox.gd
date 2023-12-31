extends HBoxContainer

var tools = {
	"Select": "Click on an element to select them",
	"Move": "Move an element from one place to another",
	"Delete": "Click an element to erase them from the structure",
	"Duplicate": "Create a look-alike element by clicking on an atom",
	"Element": "Add new atom to the structure",
	"View": "(Coming Soon) Switch between beginner view to compact view",
	"Save": "(Coming Soon) Save compound to disk",
	"Load": "(Coming Soon) Load structure from a file"
}

func _ready():
	$SelectButton.button_group.connect("pressed", __on_button_pressed)
	
	for button in get_children():
		button.connect("mouse_entered", __change_tool_desc_button.bind(button))
	for button in $"../../PanelContainer/HBoxContainer".get_children():
		button.connect("mouse_entered", __change_tool_desc_button.bind(button))
		
	$"..".connect("mouse_exited", __change_tool_desc_active)
	$"../../PanelContainer".connect("mouse_exited", __change_tool_desc_active)
	__change_tool_desc_active()

func __change_tool_desc_active():
	var button = $SelectButton.button_group.get_pressed_button()
	
	var selected = button.name.replace("Button", "")
	$"../../../VBoxContainer/Title".text = selected
	$"../../../VBoxContainer/Desc".text = tools[selected]

func __change_tool_desc_button(button: BaseButton):
	var selected = button.name.replace("Button", "")
	$"../../../VBoxContainer/Title".text = selected
	$"../../../VBoxContainer/Desc".text = tools[selected]

func __on_button_pressed(button: BaseButton):
	__change_tool_desc_button(button)
	Global.selectedTool = button.name.replace("Button", "")
