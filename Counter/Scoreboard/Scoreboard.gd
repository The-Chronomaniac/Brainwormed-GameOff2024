extends Control

@onready var hbox_container : HBoxContainer = $PanelContainer/CenterContainer/PanelContainer/HBoxContainer
@onready var counter : PanelContainer = $PanelContainer/CenterContainer/PanelContainer/HBoxContainer/Counter
@onready var word_label : Label = $PanelContainer/CenterContainer/PanelContainer/HBoxContainer/PanelContainer/Label

var counter_list : Array = []

func _ready() -> void:
	position.y = 16 # Offset from the top of the screen
	# Push original counter
	counter_list.push_back(counter)
	# Create new counters
	var number_of_counters : int = 9
	for i in range(number_of_counters):
		var new_counter = counter.duplicate()
		counter_list.push_back(new_counter)
		hbox_container.add_child.call_deferred(new_counter)
	
	# Connect scoreboard
	Level.scoreboard_update.connect(_update_counter)
	_update_counter.call_deferred(0)
	
	# Connect current word
	Level.current_word.connect(_update_current_word)

func _update_current_word(value):
	word_label.text = value

func _update_counter(value : int = 0):
	print("Update scoreboard")
	var max_number : String = ""
	for i in range(counter_list.size()):
		max_number += "9"
	
	var clamped_value = clamp(value, 0, int(max_number))
	# Convert number to an array
	var number : Array = str(clamped_value).split()
	# Count how many empty slots there will be
	var empty_slots : int = counter_list.size() - number.size()
	for i in range(empty_slots):
		number.push_front(-1)
	
	for i in range(number.size()):
		var counter_value : int = int(number[i])
		counter_list[i].set_value(counter_value)
