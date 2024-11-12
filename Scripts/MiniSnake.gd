extends Node

var position: Vector2
var current_direction
var previous_direction
var up = Vector2(0,-1)
var down = Vector2(0,1)
var left = Vector2(-1,0)
var right = Vector2(1,0)
var movement_direction: Vector2
var can_move: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
