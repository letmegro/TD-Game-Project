extends Control

"""
Nicolas Korsunski
2022-03-20

Music from Uppbeat (free for Creators!):
https://uppbeat.io/t/soundroll/tropicana
License code: MCSLR4FU9MPHI7UX
used for background temporary music
"""

func _ready():
	if GameVariables.music:
		$AudioStreamPlayer.play()
	elif GameVariables.music == false:
		$AudioStreamPlayer.stop()
	

func _on_start_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Game/Node2D.tscn")
	

func _on_settings_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://settings/settings.tscn")
	

func _on_quit_pressed():
	if GameVariables.sound:
		$VBoxContainer/AudioStreamPlayer2D.play()
		yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()
	
