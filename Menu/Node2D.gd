extends Control

"""
Nicolas Korsunski
2022-03-20

This is the main menu script.
This script is used to control and give the user the ability to get to the options as well
as quit the game or start the game and select a level in the selection scene
"""



#checks and starts up the sounds and music based on the music and sound settings
#which can be controlled through the settings menu and gamevariables script
func _ready():
	#initiates background music if the music option is true
	if GameVariables.music:
		$AudioStreamPlayer.play()
	elif GameVariables.music == false:
		$AudioStreamPlayer.stop()
		
	

#start button on pressed control
func _on_start_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		#plays sound if sound option is on
		yield(get_tree().create_timer(0.23), "timeout")
	#changes scene to the level selection scene
	get_tree().change_scene("res://LevelSelection/level_selection.tscn")
	

#changes scene to the settings scene
func _on_options_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://settings/settings.tscn")
	

#method to quit the game on press
func _on_quit_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()
	
