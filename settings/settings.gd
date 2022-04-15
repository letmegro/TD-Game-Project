extends Control

"""
"Nicolas Korsunski
"2022-04-14
"
"settings class initiates music and plays it also update the global variables 
"for sound and music based
"on user selected input.
"this scene also displays the player controls game controls
"idea: add sound and music volume control
"""

#plays the sounds and music based on variable settings
func _ready():
	#initiates checkboxes based on the global variable settings checked for true
	#unchecked for false
	$VBoxContainer/Button/CheckBox2.pressed = GameVariables.sound
	$VBoxContainer/Button/CheckBox.pressed = GameVariables.music
	if (GameVariables.music):
		$AudioStreamPlayer.play()
		
	

#returns back to main menu if back button is pressed
func _on_Button_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	
	get_tree().change_scene("res://Menu/Node2D.tscn")
	

#updates global variable if user pressed the check box 
func _on_CheckBox2_pressed():
	if GameVariables.sound: #if it has sound on
		GameVariables.sound = false
	#if sound is off it will now be on
	elif !GameVariables.sound:
		GameVariables.sound = true
	#plays sound if it is on
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	

#updates global variable if user pressed the check box
func _on_CheckBox_pressed():
	#if sound is on it will play the clic sound
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	
	if GameVariables.music: #if it has music on it will turn music off
		GameVariables.music = false
		$AudioStreamPlayer.stop()
	
	elif !GameVariables.music: #else the music will be turned on if off
		GameVariables.music = true
		$AudioStreamPlayer.play()
