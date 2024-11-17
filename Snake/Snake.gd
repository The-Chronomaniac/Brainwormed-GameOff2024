extends Node

# Directions
const up = Vector2(0, -1)
const down = Vector2(0, 1)
const left = Vector2(-1, 0)
const right = Vector2(1, 0)

var move_direction: Vector2 = up
var next_direction: Vector2 = up
var can_move: bool

# Where we store the snakes node data
var snake_segment : Array
var snake_segment_position : Array # Where we store the snakes segments position
var snake_letter_index : int = 1 # Where to place the next letter
var current_word : String = ""

var letter_scene : PackedScene = load("res://Letter/Letter.tscn")
@onready var move_timer : Timer = $DelayTime

var snake_head : Letter
var snake_head_default_scale : float = 1.3
var snake_tail : Letter
var snake_tail_default_scale : float = 0.75

var normal_speed : float = 0.3
var fast_speed : float = 0.1

func spawn_snake(x_pos, y_pos):
	# Mini snake are segements of the snake
	var snake_body = letter_scene.instantiate()
	get_tree().current_scene.add_child(snake_body)
	snake_segment.push_back(snake_body)
	snake_segment_position.push_back(Vector2(x_pos, y_pos))
	snake_body.is_snake_segment = true
	return snake_body
	
func spawn_letter_segment():
	pass
	
func move():
	if can_move:
		can_move = false	 # Cannot move again until the next timer goes off
		# Set the move direction if it isn't zero
		if not (move_direction + next_direction) == Vector2(0,0):
			move_direction = next_direction
		# Check head
		var head_segment = snake_segment[0]
		var head_position = snake_segment_position[0]
		# Set snake speed based on position
		var movement_speed = fast_speed if zone_check(snake_segment_position[0]) else normal_speed
		move_timer.wait_time = movement_speed
		# Look to next position
		var next_position : Vector2 = Vector2(head_position.x + move_direction.x, head_position.y + move_direction.y)
		snake_segment_position.push_front(next_position) # Store the latest grid position
		# Check if the snake has collided with any object in the grid
		var letter = Level.data[next_position.y][next_position.x]
		var found_letter = not letter == null
		# If the next position has a letter
		if found_letter:
			# If the letter is part of its body. Kill the snake
			if letter.is_snake_segment:
				dead()
				return
			# Otherwise add it to the body
			letter.is_snake_segment = true
			letter.modulate = Color("LightBlue")
			snake_segment.insert(snake_letter_index, letter)
			snake_letter_index += 1
			# Update user interface with current letters
			current_word += letter.value
			Level.emit_signal("current_word", current_word)
			# If player picks up 5 letters (max letter count) clear the board
			if snake_letter_index > 5:
				clear_the_board()
			# Play eat animation
			var tween = get_tree().create_tween()
			snake_head.scale *= 1.75 # Temp grow the head and eaten letter
			letter.scale *= 1.5
			tween.tween_property(snake_head, "scale", Vector2(snake_head_default_scale, snake_head_default_scale), 0.2)
			tween.parallel().tween_property(letter, "scale", Vector2(1, 1), 0.3)
			tween.play()
		else:
			# Remove the segment position from the end of the snake
			var last_segment_position = snake_segment_position.pop_back()
			Level.data[last_segment_position.y][last_segment_position.x] = null
		
		# Go through all the segments of the snake
		for i in range(snake_segment.size()):
			var current_segment = snake_segment[i]
			var current_position = snake_segment_position[i]
			# Reposition the piece
			var cell_size : Vector2 = Vector2(Level.cell_size, Level.cell_size)
			var letter_offset : Vector2 = cell_size * 0.5
			var board_offset : Vector2 = Level.board_position
			var letter_position : Vector2 = cell_size * current_position
			# Move to new posiiton visually -- Smooth tween
			var move_tween = get_tree().create_tween()
			var transition_speed = movement_speed * 0.6 if movement_speed == normal_speed else fast_speed
			move_tween.tween_property(current_segment, "global_position", board_offset + letter_position + letter_offset, transition_speed).set_trans(Tween.TRANS_SINE)
			move_tween.play()
			# Move segment to new position in level data
			Level.data[current_position.y][current_position.x] = current_segment
		
func inputs():
		if Input.is_action_just_pressed("Down") and move_direction != up:
			next_direction = down
		elif Input.is_action_just_pressed("Up") and move_direction != down:
			next_direction = up
		elif Input.is_action_just_pressed("Left") and move_direction != right:
			next_direction = left
		elif Input.is_action_just_pressed("Right") and move_direction != left:
			next_direction = right
			
func on_timer_out():
	can_move =  true
	
func initialize_snake():
	#Spawn Head and Tail
	var spawn_position : Vector2i = Level.exit_position
	# Snake head
	snake_head = spawn_snake(spawn_position.x, spawn_position.y - 1)	
	snake_head.scale = Vector2(snake_head_default_scale, snake_head_default_scale)
	snake_head.z_index = 10 # Always on top
	snake_head.modulate = Color("Yellow")
	snake_head.set_value("..")
	# Snake tale
	snake_tail = spawn_snake(spawn_position.x - 1, spawn_position.y)
	snake_tail.scale = Vector2(snake_tail_default_scale, snake_tail_default_scale)
	snake_tail.modulate = Color("Yellow").darkened(0.2)
	# Snake only moves when the can_move == true
	move_timer.timeout.connect(on_timer_out)
	move_timer.start()
	can_move = true
	# Spawn random letters
	spawn_letters.call_deferred(3)

func clear_the_board():
	# Destroy all existing letters
	var all_letters = get_tree().get_nodes_in_group("Letter")
	for letter in all_letters:
		if not letter.is_snake_segment:
			letter._kill_animation()

func spawn_letters(count : int = 3):
	clear_the_board()
	# Spawn new letters
	Level.emit_signal("letter_spawn", count)

func zone_check(check_position)-> bool:
	# Check the head position -- Only the head runs this code
	var current_segment = snake_segment[0]
	var x = check_position.x
	var y = check_position.y
	var in_safe_zone : bool = false
	var verify_word : bool = false
	# If top row and not right corner
	if y == 0 and x != Level.grid_size.x - 1:
		move_direction = right
		in_safe_zone = true
	# If right column and not bottom corner
	elif x == Level.grid_size.x - 1 and y != Level.grid_size.y - 1:
		move_direction = down
		in_safe_zone = true
	# If left and not top corner
	elif x == 0 and y != 0:
		move_direction = up
		in_safe_zone = true
	# If bottom row and middle of the level
	elif y == Level.exit_position.y and x == Level.exit_position.x:
		verify_word = true
		move_direction = up
		in_safe_zone = true
	# If bottom row and not left corner
	elif y == Level.grid_size.y - 1 and x!= 0:
		move_direction = left
		in_safe_zone = true
	# Sync up directions
	next_direction = move_direction
	# Check word
	if verify_word:
		# Only check if there is a word
		if not current_word == "":
			word_check()
			var random_letter_count : int = randi_range(2, 5)
			print("Letter count : " + str(random_letter_count))
			spawn_letters(random_letter_count) # Spawn new letters
	if in_safe_zone:
		snake_head.set_value("^^")
	else:
		snake_head.set_value("..")
	# Result
	return in_safe_zone

func word_check():
	var used_letters : Array = []
	var used_letters_index : Array = []
	var word = ""
	for i in range(snake_segment.size()):
		var letter = snake_segment[i]
		# Skip the head and tail
		if not letter == snake_head and not letter == snake_tail:
			# Capture the letters with values inside them
			if not letter.value == "":
				letter.modulate = Color("DARK_SALMON") # Set to red initially
				used_letters.push_back(letter) # Store only the letters that matter
				used_letters_index.push_back(i)
			word += letter.value
			letter.set_value("") # Clear value from word
			snake_letter_index = 1 # Reset position
	# Check the word and update the scoreboard
	var word_points = Points._calculate_word_points(word)
	# Combine all the correct letters into one segment
	if word_points > 0:
		for letter in used_letters:
			letter.modulate = Color("GREEN")
			var index = snake_segment.find(letter)
			if not index == 1: # Keep the first letter
				snake_segment.pop_at(index)
				var snake_position = snake_segment_position.pop_at(index)
				Level.data[snake_position.y][snake_position.x] = null # Clear
				letter._kill_animation()
				#letter.queue_free.call_deferred()
	# Reset current word
	current_word = ""
	Level.emit_signal("current_word", current_word)
	# Update the scoreboard
	Level.update_scoreboard(word_points)

func dead():
	print("Snake has died!")
	snake_head.modulate = Color("Red")
	snake_tail.modulate = Color("DARK_SALMON")
	snake_head.set_value("XX")
	can_move = false
	move_timer.queue_free()
	print("Snake length: " + str(snake_segment.size()))
