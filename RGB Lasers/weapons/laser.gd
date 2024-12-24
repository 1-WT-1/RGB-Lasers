extends "res://weapons/laser.gd"

var current_hue = 0.0
var color_cycle_speed = 1.0  # Speed of color cycling 

func update_laser_color(delta):
	current_hue += delta * color_cycle_speed
	if current_hue >= 1.0:
		current_hue -= 1.0

	var color = Color.from_hsv(current_hue, 1.0, 1.0)

	# Update light nodes
	flare.color = color
	beam.color = color
	diffraction.color = color

# Update the colors every frame
func _process(delta):
	if firepower > 0:
		update_laser_color(delta)
