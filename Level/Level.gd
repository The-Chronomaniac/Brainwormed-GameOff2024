extends Node

signal scoreboard_update(value)

# Where we store where the letters go
var cell_size : int = 64
var grid_size : Vector2i = Vector2i(28, 14)

# Map data
var data : Array = []

# Scoreboard
var scoreboard : int = 0

var difficulty_level : int = 0
var number_of_letters : int = 1

func _ready() -> void:
	# Create map data
	for y in range(grid_size.y):
		data.push_back(0) # Add field
		data[y] = []
		data[y].resize(grid_size.x)
		data[y].fill(0)

func _update_difficulty():
	# Updating the difficulty level increases the amount of letters on the board
	if difficulty_level == 0:
		number_of_letters = 1
	if difficulty_level > 0:
		number_of_letters = 2
	if difficulty_level > 3:
		number_of_letters = 3
	if difficulty_level > 6:
		number_of_letters = 4
	if difficulty_level > 9:
		number_of_letters = 5
	difficulty_level += 1


func update_scoreboard(value):
	scoreboard += value
	print("Scoreboard: " + str(scoreboard))
	emit_signal("scoreboard_update", scoreboard)
