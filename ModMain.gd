extends Node

const MOD_PRIORITY = 0
const MOD_NAME = "RGB Lasers"
const MOD_VERSION_MAJOR = 2
const MOD_VERSION_MINOR = 1
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""

var modPath: String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

func _init(modLoader = ModLoader):
	l("Initializing")
	
	installScriptExtension("weapons/laser.gd")
	
	# Force reload of laser scenes to ensure they pick up the new script and sound
	l("Force-reloading laser scenes")
	var laser_tscn = ResourceLoader.load("res://weapons/laser.tscn", "", true)
	if laser_tscn:
		laser_tscn.take_over_path("res://weapons/laser.tscn")
		_savedObjects.append(laser_tscn)
		
	var laster_pulse_tscn = ResourceLoader.load("res://weapons/laster-pulse.tscn", "", true)
	if laster_pulse_tscn:
		laster_pulse_tscn.take_over_path("res://weapons/laster-pulse.tscn")
		_savedObjects.append(laster_pulse_tscn)
	
	loadDLC()
	l("Initialized")

func l(msg: String, title: String = MOD_NAME, version: String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])

func installScriptExtension(path: String):
	var childPath: String = str(modPath + path)
	var childScript: Script = ResourceLoader.load(childPath)
	childScript.new()
	var parentScript: Script = childScript.get_base_script()
	var parentPath: String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)

func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader: Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")
