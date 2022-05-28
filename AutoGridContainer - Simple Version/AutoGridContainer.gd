extends GridContainer
class_name AutoGridContainer

var _node_width = -1

func _update_node_size():
	if len(get_children()) == 1:
		return -1
	
	#duplicate a node, assuming they are all the same
	$MinSizeTesting.add_child(get_child(1).duplicate())
	#set the size to the minimum
	$MinSizeTesting.get_child(0).rect_size = Vector2(0, 0)
	#get the smallest possible size they can contain
	_node_width = $MinSizeTesting.get_child(0).rect_size.x + 10
	#remove the copied node
	$MinSizeTesting.get_child(0).queue_free()


func _process(_delta: float) -> void:	
	#make the node used to test for sizing (to prevent effecting the grid's node2d control)
	if $MinSizeTesting == null:
		var min_size_testing = Node.new()
		min_size_testing.name = "MinSizeTesting"
		add_child(min_size_testing)

	#don't do anything if there are no children
	if len(get_children()) == 1:
		return

	#update the child width if not already updated
	if _node_width == -1:
		_update_node_size()
		return

	#window_size in case an issue occures with resizing
	var screen_width = min(rect_size.x, OS.window_size.x)

	#(columns - 1) means that it can still shrink in size
	columns = int(screen_width/_node_width) - 1
	columns = min(columns, get_child_count() - 1)
