extends Button

var ATOM_TSCN = preload("res://Atom.tscn")

func _ready():
	connect("pressed", _on_pressed)

func _on_pressed():
	var atom = ATOM_TSCN.instantiate()
	get_owner().register_new_atom(atom)
