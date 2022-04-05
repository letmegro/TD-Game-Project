extends Control

"""
Music from Uppbeat (free for Creators!):
https://uppbeat.io/t/soundroll/tropicana
License code: MCSLR4FU9MPHI7UX
used for background temporary music
"""

func _ready():
	$VBoxContainer/Button/CheckBox2.pressed = GameVariables.sound
	$VBoxContainer/Button/CheckBox.pressed = GameVariables.music
	if (GameVariables.music):
		$AudioStreamPlayer.play()
		
	

func _on_Button_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	
	get_tree().change_scene("res://Menu/Node2D.tscn")
	


func _on_CheckBox2_pressed():
	if GameVariables.sound: #if it has sound on
		GameVariables.sound = false
	
	elif !GameVariables.sound:
		GameVariables.sound = true
	
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	


func _on_CheckBox_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	
	if GameVariables.music: #if it has sound on
		GameVariables.music = false
		$AudioStreamPlayer.stop()
	
	elif !GameVariables.music:
		GameVariables.music = true
		$AudioStreamPlayer.play()
