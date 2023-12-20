extends Label

func _process(delta):
	if Input.is_key_pressed(KEY_I):
		analyze()

func print_tree_(tree, level=0):
	print('  '.repeat(level) + ' - ' + tree.name)
	for child in tree.get_children():
		print_tree_(child, level + 1)

func analyze():
	var trees = []
	var atoms = get_owner().get_node("Atoms").get_children()
	for atom in atoms:
		# only from the tail
		if atom.get_connection_lines().size() == 1:
			trees.append(create_tree_from(atom))
	var i = 1
	for tree in trees:
		print("TREE #" + str(i))
		print_tree_(tree)
		i += 1

func create_tree_from(atom: Node, ignoreId = -1):
	var connections = atom.get_connection_lines()
	var tree = atom.duplicate()
	tree.atomId = atom.atomId
	
	for child in tree.get_children():
		child.free()
	for connection in connections:
		if not connection["atom"].atomId == ignoreId:
			if not find_atom_from(tree, connection["atom"].atomId):
				tree.add_child(create_tree_from(connection["atom"], tree.atomId))
	return tree

func find_atom_from(tree, id):
	for child in tree.get_children():
		if child.atomId == id:
			return child
	return null
