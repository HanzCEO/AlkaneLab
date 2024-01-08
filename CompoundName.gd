extends Label

var compoundNumNames = [
	"meth", "eth", "prop", "but",
	"pent", "hex", "hept", "oct", "non", "dec"
]
var multNames = [
	'', 'di', 'tri', 'tetra', 'penta',
	'hexa', 'hepta', 'octa', 'nona', 'deca'
]
const MAIN_BRANCH_COLOR = Color.AQUAMARINE
const BRANCH_COLOR = Color.BLACK

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
	#print(mainBranch)
	#print_tree_(mainBranch["tree"])
	reset_branch_color_from_tree(mainBranch["tree"])

	color_main_branch(mainBranch)
	name_main_branch(mainBranch)

func create_tree_from(atom: Node, ignoreId = -1):
	var connections = atom.get_connection_lines()
	var tree = atom.duplicate()
	tree.atomId = atom.atomId
	tree.ref = atom
	
	for child in tree.get_children():
		child.free()
	for connection in connections:
		# Filtering
		if not connection["atom"].atomId == ignoreId:
			if not find_atom_from(tree, connection["atom"].atomId):
				var newTree = create_tree_from(connection["atom"], tree.atomId)
				newTree.parentobj = tree
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

# Step 2:
# After searching for the main branch,
# we need to color the connections to
# differentiate them from its branches.

func color_main_branch(mainBranch):
	if not mainBranch["tree"]:
		return
	
	var tree = mainBranch["tree"]
	var deepest = mainBranch["deepest"]
	
	var current_ = deepest["node"]
	var parent_ = deepest["parent"]
	while parent_ != null:
		# Color lines
		for connection in current_.ref.get_connection_lines():
			if connection["atom"].atomId == parent_.atomId:
				connection["lineNode"].default_color = MAIN_BRANCH_COLOR
				break
		current_ = parent_
		parent_ = parent_.get_parent()
		#print(current_, parent_)

func reset_checked_from_tree(tree):
	for children in tree.get_children():
		children.isChecked = false
		reset_checked_from_tree(children)

func reset_branch_color_from_tree(tree):
	for children in tree.get_children():
		for conn in children.ref.get_connection_lines():
			conn["lineNode"].default_color = Color.WHITE
		reset_branch_color_from_tree(children)

func get_branches_from_main(mainBranch):
	if not mainBranch["tree"]:
		return

	var tree = mainBranch["tree"]
	reset_checked_from_tree(tree)

	var branches = []

	# Walk the main branch for branches
	var current_ = tree
	var friend = null
	var index = 1
	while current_.get_child_count() > 0:
		for connection in current_.ref.get_connection_lines():
			if connection["lineNode"].default_color == MAIN_BRANCH_COLOR:
				# This is main branch
				var atom_ = find_atom_from(current_, connection["atom"].atomId)
				friend = atom_
			else:
				# A new branch detected
				var branchFirstAtom = find_atom_from(current_, connection["atom"].atomId)
				walk_atom_children_1(branchFirstAtom)
				branches.append({"index": index, "atom": branchFirstAtom})
		if (friend != null):
			current_ = friend
		else:
			break
		index += 1

	reset_checked_from_tree(tree)
	return branches

func walk_atom_children_1(atom):
	if not atom or atom.isChecked:
		return

	# Change connection line color to black
	for conn in atom.ref.get_connection_lines():
		conn["lineNode"].default_color = BRANCH_COLOR
	atom.isChecked = true

	for child in atom.get_children():
		walk_atom_children_1(child)

func name_branches(branches):
	var names = {}
	var namesFinal = ""
	# print(branches)
	for branch in branches:
		var length = walk_atom_children_2(branch["atom"])
		if length > compoundNumNames.size():
			continue
		if not ((compoundNumNames[length] + "yl") in names):
			names[compoundNumNames[length] + "yl"] = []
		names[compoundNumNames[length] + "yl"].append(branch["index"])
	for key in names.keys():
		names[key].sort()
		namesFinal += ",".join(names[key]) + '-' + multiplier_namer(names[key].size()) + key + ' '

	return namesFinal

func multiplier_namer(n):
	return multNames[n-1]

func walk_atom_children_2(atom):
	var lengths = [0]
	for child in atom.get_children():
		lengths.append(walk_atom_children_2_1(child, 2))
	return lengths.max()

func walk_atom_children_2_1(atom, l=1):
	var length = l # Already includes `atom`
	for child in atom.get_children():
		length += walk_atom_children_2_1(child, length + 1) - length
	return length

func name_main_branch(mainBranch):
	# TODO: Sort branch naming by alphabet
	#print_tree_(mainBranch["tree"])
	
	var branches = get_branches_from_main(mainBranch)
	var branchesNamed = ''
	if mainBranch["deepest"]["depth"] > 2:
		branchesNamed = name_branches(branches)
	reset_checked_from_tree(mainBranch["tree"])
	
	text = branchesNamed + compoundNumNames[mainBranch["deepest"]["depth"]] + "ane"
