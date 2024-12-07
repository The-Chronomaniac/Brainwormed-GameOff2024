extends Control

@export var snake_scene : Resource

var player_snake
var line_list : Array = []

@export var letter_scene : PackedScene
var rng = RandomNumberGenerator.new()

var verify_block : Letter2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn letters
	Level.letter_spawn.connect(_spawn_random_letters)

	#Spawn Snake
	player_snake = snake_scene.instantiate()
	await get_tree().process_frame
	get_tree().current_scene.add_child(player_snake)
	player_snake.initialize_snake()
	
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
	verify_block.global_position = Level.board_position + Vector2(Level.cell_size * x_position, Level.cell_size * y_position) + Vector2(Level.cell_size * 0.5, Level.cell_size * 0.5)
	verify_block.z_index = 1
	verify_block.remove_from_group("Letter")
	verify_block.scale = Vector2(1.25, 1.25)
	verify_block.set_value("@")
	# Change the block when you have enough letters to verify (one letter)
	Level.current_word.connect(_verify_block_color)
	_verify_block_color("")
	# Play animation to prove its still working
	var tween = get_tree().create_tween()
	tween.tween_property(verify_block, "position:y", -2, 0.25).as_relative()
	tween.tween_property(verify_block, "position:y", 2, 0.25).as_relative()
	tween.set_loops(0)
	tween.play()
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
	var empty_cell_left = Level.data[y_position][x_position - 1]
	var empty_cell_right = Level.data[y_position][x_position + 1]
	var empty_cell_up = Level.data[y_position - 1][x_position]
	var empty_cell_down = Level.data[y_position + 1][x_position]
	# If the level space is empty or it is not in the verify exit, spawn the letter
	if not Level.data[y_position][x_position] == null or x_position == Level.exit_position.x: # Null is empty
		_spawn_letter(letter) # Try again if not
		return
	# Only spawn letters that aren't touching to give the player room to manevur
	if not empty_cell_down == null or not empty_cell_up == null or not empty_cell_right == null or not empty_cell_left == null:
		_spawn_letter(letter) # Try again if not
		return
	# Create the letter
	var new_letter = letter_scene.instantiate()
	# Store the new data
	Level.data[y_position][x_position] = new_letter
	await get_tree().process_frame
	get_tree().current_scene.add_child(new_letter)
	new_letter.global_position = Level.board_position + Vector2(Level.cell_size * x_position, Level.cell_size * y_position) + Vector2(Level.cell_size * 0.5, Level.cell_size * 0.5)
	new_letter.set_value(letter)
	
func _physics_process(delta: float) -> void:
	player_snake.move()
	player_snake.inputs()
