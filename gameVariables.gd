"""
"Nicolas Korsunski
"2022-03-17
"
"Below is the global variables that will be used for the game mechanics like tower tracking range and all the rules
"in order to avoid hard coding everything and have it automatically use variables 
"to set the range using, etc
"""

extends Control
export var sound = true
export var music = true
var AI_Dict_Var_Keys = {
	"spider": {
		"name": "Spider", "health": 1
	},
	"fly": {
		"name": "Fly", "health": 3
	},
	"worm": {
		"name": "Worm", "health": 5
	},
	"deathworm": {
		"name": "Death Worm", "health": 7
	},
	"wasp": {
		"name": "Wasp", "health": 9
	}
}

var Player_Dict_Var_Keys = {
	"start_money": 300, #increase and decrease logic will be done in a game logic script
	"lifes": 250 #this is the default health
}

var Tower_Dict_Var_Keys = {
	"Gun1": {
		"name": "Machine Gun", "power": 1, "cost": 125, "range": 350, "rof": 2, "ShotType": "Projectile"
	},
	"Gun2": {
		"name": "Ice Gun", "power": 2, "cost": 200, "range": 450, "rof": 2, "ShotType": "IceShot"
	},
	"Gun3": {
		"name": "Cannon", "power": 4, "cost": 425, "range": 500, "rof": 3, "ShotType": "cannon"
	}
}

