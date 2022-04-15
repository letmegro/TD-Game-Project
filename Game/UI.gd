"""
"Nicolas Korsunski
"2022-03-22
"
"tower placement validation script
"in this script we do a few things for one we calculate the range of the tower
"and we set the range according to the towers dictionary description "range"
"we also change the color of the tower based on valid (green) and invalid (red)
"recommended range tower-preferred range/600.0 for valid range circle indicator scaling
"""

extends CanvasLayer

#var tower_range
#this tower is incharge of updating the radius tower and changing the colour of the radius
#asset
func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://Towers/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	
	#initiate a new sprite to show the user the range
	var _range = Sprite.new()
	_range.position = Vector2(32,32)
	#scale the image to the appropriate radius
	var scaling = GameVariables.Tower_Dict_Var_Keys[tower_type]["range"]/600.0
	_range.scale = Vector2(scaling, scaling)
	var range_asset = load("res://Tower_UI_Assets/range_overlay.png")
	_range.texture = range_asset
	_range.modulate = Color("ad54ff3c")
	
	#initiats the control of the tower radius and preview which is used
	#in the main method as well as in this script
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(_range, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0)
	

#updates teh colour of the tower assets
func update_tower_preview(new_position, color):
	get_node("TowerPreview").rect_position = new_position
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node("TowerPreview/Sprite").modulate = Color(color)
	
