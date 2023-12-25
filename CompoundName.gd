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
	var mainBranch = {"deepest": {"depth": 0}, "shallowest": {"depth": 999}}
	for tree in trees:
		#print("TREE #" + str(i))
		#print_tree_(tree)
		var ds = search_deepest_shallowest_ends_of(tree)
		if ds["deepest"]["depth"] > mainBranch["deepest"]["depth"]:
			mainBranch = ds
		elif ds["deepest"]["depth"] == mainBranch["deepest"]["depth"]:
			if ds["shallowest"]["depth"] < mainBranch["shallowest"]["depth"]:
				mainBranch = ds
		else:
			pass
		i += 1
	print(mainBranch)
	print_tree_(mainBranch["tree"])

func create_tree_from(atom: Node, ignoreId = -1):
	var connections = atom.get_connection_lines()
	var tree = atom.duplicate()
	tree.atomId = atom.atomId
	
	for child in tree.get_children():
		child.free()
	for connection in connections:
		if not connection["atom"].atomId == ignoreId:
			if not find_atom_from(tree, connection["atom"].atomId):
				var newTree = create_tree_from(connection["atom"], tree.atomId)
				tree.add_child(newTree)
	return tree

func search_deepest_shallowest_ends_of(tree: Node):
	var ends = find_end(tree)
	var shallowest = ends[0]
	var deepest = ends[0]
	for end in ends:
		if end.depth > deepest.depth:
			deepest = end
		if end.depth < shallowest.depth:
			shallowest = end
	return {"deepest": deepest, "shallowest": shallowest, "tree": tree}

func find_end(current, depth=1, parent=null):
	var ends = []
	for child in current.get_children():
		if child.get_child_count() == 0:
			ends.append({"node":child, "depth": depth, "parent": parent})
		else:
			ends.append_array(find_end(child, depth + 1, child))
	return ends

func find_atom_from(tree, id):
	for child in tree.get_children():
		if child.atomId == id:
			return child
	return null
