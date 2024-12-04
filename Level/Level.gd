extends Node

signal scoreboard_update(value)
signal letter_spawn(number_of_letters)
signal current_word(value)

# Where we store where the letters go
var cell_size : int = 16
var grid_size : Vector2i = Vector2i(14, 8)
var board_position : Vector2 = Vector2.ZERO

# Map data
var data : Array = []

# Scoreboard
var scoreboard : int = 0

var difficulty_level : int = 0
var number_of_letters : int = 1

var exit_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	# Create map data
	for y in range(grid_size.y):
		data.push_back(null) # Add field
		data[y] = []
		data[y].resize(grid_size.x)
		data[y].fill(null)
	# Set the exit cell
	exit_position = Vector2(1, Level.grid_size.y - 1)

func update_scoreboard(value):
	scoreboard += value
	print("Scoreboard: " + str(scoreboard))
	emit_signal("scoreboard_update", scoreboard)
