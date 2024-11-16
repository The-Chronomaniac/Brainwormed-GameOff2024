extends Node

var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction: Vector2 = right
var next_direction: Vector2 = right
var can_move: bool
var snake: Array
@export var msnake : PackedScene
@export var move_timer : Timer
var previous_direction: Vector2
var minisnake
const grid_offset = Vector2(64,64)
var just_eaten =  false

func spawn_snake(x_pos, y_pos, segment_name, movedir):
	minisnake = msnake.instantiate()
	get_tree().current_scene.add_child(minisnake)
	minisnake.global_position = Vector2(Level.cell_size * x_pos, Level.cell_size * y_pos) + grid_offset
	minisnake.play(segment_name)
	can_move = true
	minisnake.move_dir = movedir
	Level.data[y_pos][x_pos] = minisnake
	snake.append(minisnake)
	minisnake.x_pos = x_pos
	minisnake.y_pos = y_pos
	minisnake.segment_name = segment_name
	
func spawn_letter_segment():
	pass
	
func move():
	if can_move:
		if (move_direction + next_direction == Vector2(0,0)):
			pass
		else:
			move_direction = next_direction
		just_eaten = false
		for i in range(snake.size()):
			var current = snake[i]
			if i == 0:
				move_timer.wait_time = .03  if safe_zone_check() else .15
				previous_direction = current.move_dir
				current.move_dir = move_direction
				#Do Collisions
				Level.data[current.y_pos][current.x_pos] = 0
				current.x_pos += current.move_dir.x
				current.y_pos += current.move_dir.y 
				var piece = Level.data[current.y_pos][current.x_pos]
				if (piece is not int) and piece.is_snake_segment:
					dead()
				elif(piece is not int):
					piece.x_pos = current.x_pos - current.move_dir.x
					piece.y_pos = current.y_pos - current.move_dir.y
					piece.global_position -= Vector2(Level.cell_size, Level.cell_size) * current.move_dir
					piece.is_snake_segment = true
					snake.insert(1, piece)
					Level.data[piece.y_pos][piece.x_pos] = piece
					just_eaten = true
							
				current.global_position += Vector2(Level.cell_size, Level.cell_size) * current.move_dir
			
				Level.data[current.y_pos][current.x_pos] = current
				print("X" + str(snake[0].x_pos) + " Y:" + str(snake[0].y_pos))
			elif !just_eaten:
				current.move_dir = previous_direction
				current.global_position += Vector2(Level.cell_size, Level.cell_size) * current.move_dir
				Level.data[current.y_pos][current.x_pos] = 0
				current.x_pos += current.move_dir.x
				current.y_pos += current.move_dir.y
				Level.data[current.y_pos][current.x_pos] = current
				previous_direction = current.move_dir
				
				
		can_move = false	
		
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
	spawn_snake(6, 4, "Head", right)	
	spawn_snake(5, 4, "Tail", right)
	move_timer.timeout.connect(on_timer_out)
	move_timer.start()
	
func safe_zone_check()-> bool:
	var current = snake[0]
	var x = current.x_pos
	var y = current.y_pos
	if y == 0 and x != 27:
		move_direction = right
		return true
	elif x == 27 and y != 13:
		move_direction = down
		return true
	elif x == 0 and y != 0:
		move_direction = up
		return true
	elif y == 13 and x == 14 and move_direction != down:
		move_direction = up
		return true
	elif y == 13 and x!= 0:
		move_direction = left
		return true
	else:
		return false
		

func dead():
	can_move = false
