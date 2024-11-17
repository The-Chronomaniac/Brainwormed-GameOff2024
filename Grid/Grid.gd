extends Control

@onready var letter_panel : Panel = $LetterZone
@onready var safe_panel : Panel = $SafeZone
@onready var line : Line2D = $Line2D
@onready var bottom_panel : Panel = $BottomPanel
@export var snake_scene : Resource

var player_snake
var line_list : Array = []

var letter_scene = preload("res://Letter/Letter.tscn")
var rng = RandomNumberGenerator.new()

var verify_block : Letter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var skin_color = "Gray"
	# Create the grid
	safe_panel.position = Vector2.ZERO
	safe_panel.size = Level.grid_size * Level.cell_size
	safe_panel.modulate = Color(skin_color).darkened(0.7)
	
	# Create the letter zone
	letter_panel.size = Vector2((Level.grid_size.x - 2) * Level.cell_size, (Level.grid_size.y - 2) * Level.cell_size)
	letter_panel.position = Vector2(Level.cell_size, Level.cell_size)
	letter_panel.modulate = Color(skin_color).darkened(0.5)
	
	# Bottom panel
	bottom_panel.size = safe_panel.size
	bottom_panel.position = safe_panel.position + Vector2(0, 256)
	bottom_panel.modulate = Color(skin_color).darkened(0.3)
	
	# Position
	Level.board_position = letter_panel.global_position
	line.default_color = Color(skin_color).darkened(0.8)
	
	# Draw grid lines
	for x in range(Level.grid_size.x):
		if x > 0:
			var new_line = line.duplicate()
			new_line.position = safe_panel.position
			new_line.points = [Vector2(Level.cell_size * x, 0), Vector2(Level.cell_size * x, Level.grid_size.y * Level.cell_size)]
			add_child(new_line)
	for y in range(Level.grid_size.y):
		if y > 0:
			var new_line = line.duplicate()
			new_line.position = safe_panel.position
			new_line.points = [Vector2(0, Level.cell_size * y), Vector2(Level.grid_size.x * Level.cell_size, Level.cell_size * y)]
			add_child(new_line)
	
	#Spawn Snake
	player_snake = snake_scene.instantiate()
	await get_tree().process_frame
	get_tree().current_scene.add_child(player_snake)
	player_snake.initialize_snake()
	
	# Spawn letters
	Level.letter_spawn.connect(_spawn_random_letters)
	
	# Spawn verify block
	_spawn_verify_block()

func _spawn_random_letters(letter_count : int = 3):
	print("Spawn letters!")
	# Spawn some letters
	var generate_a_word = RandomLetters.generate_random_letters(letter_count)
	for letter in generate_a_word.split():
		_spawn_letter(letter)

func _spawn_verify_block():
	# Create the letter
	verify_block = letter_scene.instantiate()
	var x_position = Level.exit_position.x
	var y_position = Level.exit_position.y
	# Place on map but with no value
	await get_tree().process_frame
	get_tree().current_scene.add_child(verify_block)
	verify_block.global_position = safe_panel.global_position + Vector2(Level.cell_size * x_position, Level.cell_size * y_position) + Vector2(Level.cell_size * 0.5, Level.cell_size * 0.5)
	verify_block.z_index = 1
	verify_block.remove_from_group("Letter")
	verify_block.scale = Vector2(1.25, 1.25)
	verify_block.set_value("@")
	# Change the block when you have enough letters to verify (one letter)
	Level.current_word.connect(_verify_block_color)
	_verify_block_color("")
	# Change scale when you verify
	Level.scoreboard_update.connect(_verify_block_scale)

func _verify_block_color(current_word):
	# Change color when you can verify
	verify_block.modulate = Color("Pink") if current_word == "" else Color("CHARTREUSE")

func _verify_block_scale(points):
	# Bump it up when you hit it
	var tween_verify = get_tree().create_tween()
	verify_block.scale *= 2.0
	tween_verify.tween_property(verify_block, "scale", Vector2.ONE, 0.2)
	tween_verify.play()

func _spawn_letter(letter):
	var safe_margin : int = 1
	# Spawn at a random location
	var x_position : int = randi_range(safe_margin, Level.grid_size.x - 1 - safe_margin)
	var y_position : int = randi_range(safe_margin, Level.grid_size.y - 1 - safe_margin)
	# Check if any letters are too close
	var empty_cell_left : bool = Level.data[y_position][x_position - 1] == null
	var empty_cell_right : bool = Level.data[y_position][x_position + 1] == null
	var empty_cell_up : bool = Level.data[y_position - 1][x_position] == null
	var empty_cell_down : bool = Level.data[y_position + 1][x_position] == null
	# If the level space is empty or it is not in the verify exit, spawn the letter
	if not Level.data[y_position][x_position] == null or x_position == Level.exit_position.x: # Null is empty
		_spawn_letter(letter) # Try again if not
		return
	# Only spawn letters that aren't touching to give the player room to manevur
	if not empty_cell_down and not empty_cell_up and not empty_cell_right and not empty_cell_left:
		_spawn_letter(letter) # Try again if not
		return
	# Create the letter
	var new_letter = letter_scene.instantiate()
	# Store the new data
	Level.data[y_position][x_position] = new_letter
	await get_tree().process_frame
	get_tree().current_scene.add_child(new_letter)
	new_letter.global_position = safe_panel.global_position + Vector2(Level.cell_size * x_position, Level.cell_size * y_position) + Vector2(Level.cell_size * 0.5, Level.cell_size * 0.5)
	new_letter.set_value(letter)
	
func _physics_process(delta: float) -> void:
	player_snake.move()
	player_snake.inputs()
