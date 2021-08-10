extends Node

const CONFIG_DIR: = "user://" 
const CONFIG_FILE_NAME: = "settings.cfg"
const INPUT_SECTION_KEY = 'inputs'

var configFile = ConfigFile.new()
var configFileLoad


func _init():
	configFileLoad = configFile.load(CONFIG_DIR + CONFIG_FILE_NAME)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

func save_settings()->void:
	save_settings_resource()

func load_settings()->bool:
	if configFileLoad == 7: # file not created
		save_settings()
	else:
		print("error code open file = ", configFileLoad)
	if configFileLoad != OK:
		return false
	#load input data
	SettingsControls.set_input_data(configFile.get_section_keys(INPUT_SECTION_KEY))
	return true
	
func save_settings_resource() -> void:
	# save input data
	for input in SettingsControls.get_input_data():
		print ("input = ", input)
	
	configFile.save(CONFIG_DIR + CONFIG_FILE_NAME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
