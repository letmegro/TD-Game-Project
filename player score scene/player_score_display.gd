extends Node2D
"""
"Nicolas Korsunski
"
"this scene is simply to display the player score nothing more
"last updated: 2022-04-14
"""
#idea: should find a way to store in memory player record
#adds the player's scores to the board for viewing
func _ready():
	#display the scores that were updated in the game
	$background/display_score/high_score.text = "High Score: " + String(GameVariables.player_high_score)
	$background/display_score/new_score.text  = "New Score: "  + String(GameVariables.player_score)
	

#when pressed continue will sent player back to main menu
func _on_Button_pressed():
	#when continue is pressed the game moves on to the main menu
	get_tree().change_scene("res://Menu/Node2D.tscn")
	
