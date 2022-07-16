extends Control

#"soft" because it isn't enforced if the grid wouldn't fit otherwise
export var soft_minimum_columns : int = 2
#these should come from the theme or from theme overrides
export var grid_hseperation : int = 4
export var grid_vseperation : int = 4

var _node_width = -1
var _node_height = -1

onready var grid_container = $Scroll/VBox/GridContainer

func _update_node_size():
	if len(grid_container.get_children()) == 0:
		return -1
	
	#duplicate a node, assuming they are all the same
	$MinSizeTesting.add_child(grid_container.get_child(0).duplicate())
	#set the size to the minimum
	$MinSizeTesting.get_child(0).rect_size = Vector2(0, 0)
	
	#get the smallest possible size they can contain
	_node_width = $MinSizeTesting.get_child(0).rect_size.x
	_node_height = $MinSizeTesting.get_child(0).rect_size.y
	#plus any seperation due to the grid
	_node_width += grid_hseperation
	_node_height += grid_vseperation
	
	#remove the copied node
	$MinSizeTesting.get_child(0).queue_free()


func _process(_delta: float) -> void:
	_move_children_to_grid()
	
	#don't do anything if there are no children
	if len(grid_container.get_children()) == 0:
		return
	#don't do anything if the node's haven't got a size yet
	if _node_width == -1 or _node_height == -1:
		_update_node_size()
		return
	
	#window_size in case an issue occures with resizing
	var screen_width = min(rect_size.x, OS.window_size.x)
	var screen_height = min(rect_size.y, OS.window_size.y)
	
	#(columns - 1) means that it can still shrink in size
	grid_container.columns = max(1, int(screen_width/_node_width) - 1)
	#don't allow more columns than children (wasted space)
	grid_container.columns = min(grid_container.columns, grid_container.get_child_count())
	
	#this is used to adjust the columns so that maximum space avalible is used
	for _i in 10:
		var empty_rows = _calculate_empty_rows(grid_container.columns, screen_height)
		
		#check if perfect height already
		if empty_rows <= 0:
			break
		
		#disallow single width (unless required previously)
		if grid_container.columns <= soft_minimum_columns:
			break
		
		#check that it won't need to scroll if columns change
		if _get_rows(grid_container.columns - 1) * _node_height > screen_height:
			break
		
		grid_container.columns -= 1


func _calculate_empty_rows(columns, screen_height):
	var rows = _get_rows(columns)
	
	var height_not_used : int = screen_height - rows * _node_height
	var empty_rows : int = height_not_used / _node_height
	
	return empty_rows


func _get_rows(columns):
	# rows = children // columns + 1 (if remainder)
	var rows = grid_container.get_child_count() / columns
	rows += 1 if grid_container.get_child_count() % columns != 0 else 0
	
	return rows


func _move_children_to_grid():
	#puts the children into the grid container
	#ignores the first 2 children (container and size tester)
	for i in range(2, get_child_count()):
		var child = get_child(2)
		remove_child(child)
		grid_container.add_child(child)

#allow getting nodes from the grid (null, no error version)
func get_node_from_grid(node_path : NodePath) -> Node:
	if grid_container.has_node(node_path):
		return grid_container.get_node(node_path)
	else:
		return null
