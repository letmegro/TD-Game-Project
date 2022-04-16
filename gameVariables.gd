"""
"Nicolas Korsunski
"2022-04-15
"
"last balanced: 2022-04-15
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
		"name": "Spider", "health": 1, "worth": 12
	},
	"fly": {
		"name": "Fly", "health": 3, "worth": 14
	},
	"worm": {
		"name": "Worm", "health": 5, "worth": 19
	},
	"deathworm": {
		"name": "Death Worm", "health": 7, "worth": 21
	},
	"wasp": {
		"name": "Wasp", "health": 10, "worth": 23
	}
}

#player attributes
var Player_Dict_Var_Keys = {
	"start_money": 200, #increase and decrease logic will be done in a game logic script
	"lifes": 100 #this is the default health
}

#tower dictionary defining tower attributes
var Tower_Dict_Var_Keys = {
	"Gun1": {
		"name": "Machine Gun", "power": 1, "cost": 125, "range": 350, "rof": 2, "ShotType": "Projectile"
	},
	"Gun2": {
		"name": "Ice Gun", "power": 3, "cost": 250, "range": 450, "rof": 2, "ShotType": "IceShot"
	},
	"Gun3": {
		"name": "Cannon", "power": 5, "cost": 500, "range": 500, "rof": 3, "ShotType": "cannon"
	}
}

