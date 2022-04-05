extends Control
export var sound = true
export var music = true
var AI_Dict_Var_Keys = {
	"enemy1": {
		"name": "Spider", "health": 1
	},
	"enemy2": {
		"name": "Fly", "health": 3
	},
	"enemy3": {
		"name": "Worm", "health": 5
	},
	"enemy4": {
		"name": "Death Worm", "health": 7
	},
	"enemy5": {
		"name": "Wasp", "health": 9
	}
}

var Player_Dict_Var_Keys = {
	"start_money": 300, #increase and decrease logic will be done in a game logic script
	"lifes": 250 #this is the default health
}

var Tower_Dict_Var_Keys = {
	"tower1": {
		"name": "Tower1", "power": 1, "cost": 125, "range": 350
	},
	"tower2": {
		"name": "Tower2", "power": 2, "cost": 200, "range": 450
	},
	"Tower3": {
		"name": "Tower3", "power": 4, "cost": 425, "range": 500
	}
}

