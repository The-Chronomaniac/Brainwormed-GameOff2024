extends Node2D

var alphabet : Array = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

@onready var shadow : Node2D = $Shadow
@onready var shadow_panel : Panel = $Shadow/Graphic

@onready var block : Node2D = $Block
@onready var block_panel : PanelContainer = $Block/Graphic
@onready var label : Label = $Block/Graphic/Letter

var value : String = ""

var tween : Tween = create_tween()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#value = alphabet.pick_random()
	label.text = value
	# Shadow size
	shadow_panel.size = Vector2(Level.cell_size - 6, Level.cell_size - 6)
	shadow_panel.position = -shadow_panel.size * 0.5
	# Block position
	block_panel.size = Vector2(Level.cell_size, Level.cell_size)
	block_panel.position = -block_panel.size * 0.5
	# Create animation
	var bounce_height : float = Level.cell_size * 0.125
	var bounce_speed : float = 0.5
	tween.set_trans(tween.TransitionType.TRANS_SINE)
	tween.tween_property(block, "position:y", -bounce_height, bounce_speed)
	tween.tween_property(block, "position:y", -2.0, bounce_speed)
	tween.set_loops()
	tween.play()

func set_value(letter):
	value = letter
	label.text = value

func _process(delta: float) -> void:
	shadow.modulate.a = remap(block.position.y, 0.0, -32.0, 0.4, 0.2)

func _on_tree_exited() -> void:
	tween.kill()
