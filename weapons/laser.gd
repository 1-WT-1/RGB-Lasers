extends "res://weapons/laser.gd"

var enable_caramel = true
var enable_rgb = true
var current_hue = 0.0
var color_cycle_speed = 1.0 # Speed of color cycling

func _ready():
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
	if ConfigDriver:
		var cfg_caramel = ConfigDriver.__get_value("RGBLasers", "RGBLASERS_SETTINGS", "enable_caramel")
		if cfg_caramel != null:
			enable_caramel = cfg_caramel
			
		var cfg_rgb = ConfigDriver.__get_value("RGBLasers", "RGBLASERS_SETTINGS", "enable_rgb")
		if cfg_rgb != null:
			enable_rgb = cfg_rgb
			
		var cfg_speed = ConfigDriver.__get_value("RGBLasers", "RGBLASERS_SETTINGS", "color_cycle_speed")
		if cfg_speed != null:
			color_cycle_speed = cfg_speed


	if enable_caramel and audioFire and not pulse:
		var caramel = load("res://RGB-Lasers/weapons/caramel.mp3str")
		if caramel:
			audioFire.stream = caramel

func update_laser_color(delta):
	current_hue += delta * color_cycle_speed
	if current_hue >= 1.0:
		current_hue -= 1.0

	var color = Color.from_hsv(current_hue, 1.0, 1.0)

	# Update light nodes
	flare.color = color
	beam.color = color
	diffraction.color = color

func _process(delta):
	if not enable_rgb:
		return
		
	if firepower > 0 or afterImage > 0:
		update_laser_color(delta)
