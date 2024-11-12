extends PanelContainer

@onready var label : Label = $Label

var target_number : int = 0
var current_number : float = 0.0
var previous_shown_number : int = 0

func _on_ready():
	set_physics_process(false) # Process nothing
	
func set_value(value : int = 0):
	if value == -1:
		label.modulate.a = 0.2
		label.text = "0"
		return
	target_number = value
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Count upward until you hit the number
	current_number += 0.1
	# Show the number as it flips
	var shown_number : int = int(current_number) % 10
	label.text = str(shown_number)
	
	if not shown_number == previous_shown_number:
		_number_changed()
	previous_shown_number = shown_number
	
	# Stop when you reach the target
	if shown_number == target_number:
		current_number = target_number
		set_physics_process(false)

func _number_changed():
	var tween = create_tween()
	label.modulate.a = 0.0
	tween.tween_property(label, "modulate:a", 1.0, 0.1)
	tween.play()
