class_name Letter2
extends Node2D

var alphabet : Array = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

@onready var block : Node2D = $Block

@onready var segmentsprite : AnimatedSprite2D = $Block/Segment
@onready var lettersprite : AnimatedSprite2D = $Block/Segment/Letter

var is_snake_segment = false

var value : String = ""

var tween : Tween = create_tween()

var spawn_initial_scale : Vector2 = Vector2.ZERO
var spawn_final_scale : Vector2 = Vector2.ONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#value = alphabet.pick_random()
	lettersprite.play(value)
	# Block position
	# Create animation
	var bounce_height : float = Level.cell_size * 0.125
	var bounce_speed : float = 0.5
	tween.set_trans(tween.TransitionType.TRANS_SINE)
	tween.tween_property(block, "position:y", -bounce_height, bounce_speed)
	tween.tween_property(block, "position:y", -2.0, bounce_speed)
	tween.set_loops()
	tween.play()
	# Spawn animation
	var spawn = get_tree().create_tween()
	spawn.tween_property(block, "scale", spawn_final_scale, 0.2)
	spawn.play()

func set_value(letter):
	value = letter
	# Only process letters and blank values in the animatedSprite player
	if not alphabet.find(value.to_upper()) == -1 or value == "blank":
		lettersprite.play(letter)

func _process(delta: float) -> void:
	pass

func _on_tree_exited() -> void:
	tween.kill()

func _kill_animation():
	# Nullify it's value
	set_value("")
	remove_from_group("Letter") # Group name is how I search for the object to clear the board. By removing it from the search. I can't accidently delete it twice
	# Play the death animation
	var kill_tween = get_tree().create_tween()
	kill_tween.tween_property(block, "scale", spawn_initial_scale, 0.4).set_trans(Tween.TRANS_BOUNCE)
	kill_tween.play()
	# Destroy the object after death animation plays
	await kill_tween.finished
	queue_free()
