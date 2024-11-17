extends Node2D

var alphabet : Array = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

var high_frequency_letter_weights : Dictionary = {
	"a": 0.08167, "b": 0.01492, "c": 0.02782, "d": 0.04253, "e": 0.12702, "f": 0.02228, 
	"g": 0.02015, "h": 0.06094, "i": 0.06966, "j": 0.00153, "k": 0.00772, "l": 0.04025, 
	"m": 0.02406, "n": 0.06749, "o": 0.07507, "p": 0.01929, "q": 0.00095, "r": 0.05987, 
	"s": 0.06327, "t": 0.09056, "u": 0.02758, "v": 0.00978, "w": 0.02360, "x": 0.00150, 
	"y": 0.01974, "z": 0.00074
}

func _ready() -> void:
	var word = "Zonke"
	await get_tree().process_frame
	Level.update_scoreboard(_calculate_word_points(word))

func _calculate_letter_points(letter):
	var letter_value : float = high_frequency_letter_weights[letter.to_lower()]
	var points : float = 10 / letter_value
	if points > 1000:
		points = 1000 + (points * 0.1)
	return (ceil(points * 0.005) * 50) * 0.1

func _calculate_word_points(word):
	var points : int = 0
	var word_array : Array = word.split()
	for letter in word_array:
		points += _calculate_letter_points(letter)
	
	print(word + " : " + str(points) + "!!")
	return points * (word_array.size() * 10)
