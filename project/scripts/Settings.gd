extends Node

const CONFIG_DIR: = "user://" 
const CONFIG_FILE_NAME: = "settings.cfg"
const INPUT_SECTION_KEY = 'inputs'

var configFile = ConfigFile.new()
var configFileLoad


func _init():
	configFileLoad = configFile.load(CONFIG_DIR + CONFIG_FILE_NAME)

func _ready():
	load_settings()

func save_settings()->void:
	save_settings_resource()

func load_settings()->bool:
	if configFileLoad == 7: # file not created
		save_settings()
	if configFileLoad != OK:
		print("error code open file = ", configFileLoad)
		return false
	#load input data
	var load_config_data_input = {}
	var load_config_data_inputs = configFile.get_section_keys(INPUT_SECTION_KEY)
	for config_input in load_config_data_inputs:
		var load_config_input = configFile.get_value(INPUT_SECTION_KEY, config_input, false)
		if load_config_input:
			load_config_data_input[config_input] = load_config_input
	if load_config_data_input:
		SettingsControls.set_input_data(load_config_data_input)
	else:
		SettingsControls.default_controls()
	return true
	
func save_settings_resource() -> void:
	# save input data
	var inputs = SettingsControls.get_input_data()
	for input in inputs:
		configFile.set_value(INPUT_SECTION_KEY, input, inputs[input])
	
	configFile.save(CONFIG_DIR + CONFIG_FILE_NAME)
