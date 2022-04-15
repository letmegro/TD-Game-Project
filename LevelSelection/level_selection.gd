extends Node2D

"""
"Nicolas Korsunski
"
"This scene is just a quick scene to allow the user to pick a level they want to play
"This scene also plays the same cut scene for both levels after a level is selected
"idea: make a second scene for the game to prevent repetative scenes
"last updated 2022-04-15
"""

#to control the skip ability to allow user to skip scene
var in_cutscene = false
#level type control selected to control which scene is changed to 
#when in a cutscene and cutscene is skipped
var selected = 0
#plays background music if true in settings
func _ready():
	if GameVariables.music:
		$background_music.play()
	#make video invisible to not have the scene overlay on top of user level
	#selection choice
	$VideoPlayer.visible = false
	

#skip scene method
func _input(event):
	if event.is_action_pressed("skip") and in_cutscene:
		$VideoPlayer.stop()
		if selected == 1:
			get_tree().change_scene("res://Game/Node2D.tscn")
		elif selected == 2:
			get_tree().change_scene("res://Game/Level2.tscn")
		
	

#method to play the scene
func play_cutscene():
	$background_music.stop()
	#checks to see if music is off then cut scene will also be mute
	if GameVariables.music == false:
		$VideoPlayer.volume = 0
	else:
		$VideoPlayer.volume = 0.5
	$VideoPlayer.visible = true
	$VideoPlayer.play()
	#in future could have user set volume 0 - 100
	#change it back to full volume
	
	

#level 1 selected and scene changed here
func _on_level1_pressed():
	if GameVariables.sound:
		$click_sound.play()
		yield(get_tree().create_timer(0.5), "timeout")
	in_cutscene = true
	selected = 1
	play_cutscene()
	yield(get_tree().create_timer(7.9), "timeout")
	get_tree().change_scene("res://Game/Node2D.tscn")
	

#level 2 selected and scene changed here
func _on_level2_pressed():
	if GameVariables.sound:
		$click_sound.play()
		yield(get_tree().create_timer(0.5), "timeout")
	in_cutscene = true
	selected = 2
	play_cutscene()
	yield(get_tree().create_timer(7.9), "timeout")
	get_tree().change_scene("res://Game/Level2.tscn")
	
