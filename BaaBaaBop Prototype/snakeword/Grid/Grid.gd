extends Control

@onready var letter_panel : Panel = $LetterZone
@onready var safe_panel : Panel = $SafeZone
@onready var line : Line2D = $Line2D
@onready var bottom_panel : Panel = $BottomPanel

var line_list : Array = []

var letter_scene = preload("res://Letter/Letter.tscn")
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the grid
	safe_panel.position = Vector2.ZERO
	safe_panel.size = Level.grid_size * Level.cell_size
	# Create the letter zone
	letter_panel.size = Vector2((Level.grid_size.x - 2) * Level.cell_size, (Level.grid_size.y - 2) * Level.cell_size)
	letter_panel.position = Vector2(Level.cell_size, Level.cell_size)
	letter_panel.modulate.a = 0.15
	# Bottom panel
	bottom_panel.size = safe_panel.size
	bottom_panel.position = safe_panel.position + Vector2(0, 64)
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
	
	# Spawn some letters
	var generate_a_word = RandomLetters.generate_random_letters(3)
	for letter in generate_a_word.split():
		print(letter)
		_spawn_letter(letter)
	
	#await get_tree().create_timer(1.0).timeout
	#print(Level.data)

func _spawn_letter(letter):
	var safe_margin : int = 1
	# Spawn at a random location
	var x_position : int = randi_range(safe_margin, Level.grid_size.x - 1 - safe_margin)
	var y_position : int = randi_range(safe_margin, Level.grid_size.y - 1 - safe_margin)
	# If the level space is empty, spawn it
	if not Level.data[y_position][x_position] == 0: # ZERO is consider
		_spawn_letter(letter) # Try again if not
		return
	# Store the new data
	Level.data[y_position][x_position] = 1
	# Create the letter
	var new_letter = letter_scene.instantiate()
	await get_tree().process_frame
	get_tree().current_scene.add_child(new_letter)
	new_letter.global_position = safe_panel.global_position + Vector2(Level.cell_size * x_position, Level.cell_size * y_position) + Vector2(Level.cell_size * 0.5, Level.cell_size * 0.5)
	new_letter.set_value(letter)
	Level.data[y_position][x_position] = new_letter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
