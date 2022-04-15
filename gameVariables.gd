"""
"Nicolas Korsunski
"2022-04-15
"
"Below is the global variables that will be used for the game mechanics like tower tracking range and all the rules
"in order to avoid hard coding everything and have it automatically use variables 
"to set the range using, etc
"""

extends Control
#for user variable controls
export var sound = true
export var music = true

#player high score 
var player_high_score = 0

#player accumulated score in game
var player_score = 0

#enemy Dictionary defining what each enemy is and its attributes
var AI_Dict_Var_Keys = {
	"spider": {
		"name": "Spider", "health": 1, "worth": 15
	},
	"fly": {
		"name": "Fly", "health": 3, "worth": 20
	},
	"worm": {
		"name": "Worm", "health": 5, "worth": 25
	},
	"deathworm": {
		"name": "Death Worm", "health": 7, "worth": 30
	},
	"wasp": {
		"name": "Wasp", "health": 9, "worth": 35
	}
}

#player attributes
var Player_Dict_Var_Keys = {
	"start_money": 300, #increase and decrease logic will be done in a game logic script
	"lifes": 250 #this is the default health
}

#tower dictionary defining tower attributes
var Tower_Dict_Var_Keys = {
	"Gun1": {
		"name": "Machine Gun", "power": 1, "cost": 125, "range": 350, "rof": 2, "ShotType": "Projectile"
	},
	"Gun2": {
		"name": "Ice Gun", "power": 3, "cost": 200, "range": 450, "rof": 2, "ShotType": "IceShot"
	},
	"Gun3": {
		"name": "Cannon", "power": 5, "cost": 425, "range": 500, "rof": 3, "ShotType": "cannon"
	}
}

