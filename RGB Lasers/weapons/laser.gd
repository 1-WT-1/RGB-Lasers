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
	# diffraction.color = color

# Modify the _physics_process function to include color updating
func _physics_process(delta):
	if firepower > 0:
		var freq = getFrequency()
		var frat = pulsesPerSecond / freq
		var pd = getPowerDraw() * 1000
		var energyRequired = delta * firepower * pd
		if pulse:
			cycle += delta * freq
			if cycle > 1:
				cycle -= 1
				energyRequired = firepower * pd * pulseLength * frat
			else :
				energyRequired = 0

		var energy = ship.drawEnergy(energyRequired)
		if randf() > getChoke():
			energy = 0
		
		if energy > 0 and energy >= energyRequired * 0.9:
			#Color Update
			update_laser_color(delta)
			if randf() < wearChance:
				var powerFactor = pow(pd / powerDraw, 2)
				ship.changeSystemDamage(key, "wear", delta * powerFactor * frat / wearChance, getDamageCapacity("wear"))
			readpower = firepower
			var wear = ship.getSystemDamage(key, "wear")
			var wearPower = 1.0 - clamp(pow(wear / getDamageCapacity("wear"), 2), 0, 1)
			energy *= wearPower
			if not audioFire.playing and ship.isPlayerControlled():
				audioFire.play()
			var space_state = get_world_2d().direct_space_state
			var hitpoint = space_state.intersect_ray(global_position, global_position + ray.rotated(global_rotation), ship.physicsExclude, 35)
			var distance = maxDistance
			if ship.isPlayerControlled():
				CurrentGame.logEvent("LOG_EVENT_DIVE", {"LOG_EVENT_DETAILS_LASER":delta})

			if hitpoint and Tool.claim(hitpoint.collider):
				var kp = clamp(kineticPart * frat, 0.0, 1.0)
				var output = energy * (power / powerDraw)
				var hitDistance = global_position.distance_to(hitpoint.position)
				if hitpoint.collider.has_method("applyEnergyDamage") and kp < 1:
					hitpoint.collider.applyEnergyDamage(output * (1 - kp), hitpoint.position, delta)
				if hitpoint.collider.has_method("applyKineticDamage") and kp > 0:
					hitpoint.collider.applyKineticDamage(output * (kp) * kineticDamageScale, hitpoint.position, delta)
				if hitpoint.collider.has_method("applyHostility"):
					hitpoint.collider.applyHostility(
						ship.faction, 
						((output / hostilityDamagePerSecond) * (1 - clamp((hitDistance - hostilityDistance) / hostilityDistance, 0, 1)))
					)
				ship.youHit(hitpoint.collider, delta * 0.2)
				flare.global_position = hitpoint.position
				flare.visible = true
				distance = (global_position - hitpoint.position).length()
				flare.rotation = randf() * 2 * PI
				if randf() < flareLighlagChance and ship.inside <= 0:
					CurrentGame.addLightLagEvent(CurrentGame.globalCoords(flare.global_position), flare.color, flareEnergy * wearPower)
				Tool.release(hitpoint.collider)
			else :
				flare.visible = false
			
			beam.scale = Vector2(1, distance / 512)
			beam.visible = true
			var ps = pd / powerDraw
			diffraction.energy = diffractionEnergy * ps
			diffraction.visible = true
			diffraction.rotation = randf() * 2 * PI
			flare.energy = flareEnergy * ps * wearPower
			beam.energy = beamEnergy * ps * wearPower
			afterImage = afterImageTime
		else :
			fade(delta)
			audioFire.stop()
	else :
		audioFire.stop()
		fade(delta)
		readpower = 0
		if pulse:
			cycle += delta * pulsesPerSecond
			if cycle > 1:
				cycle = 1
