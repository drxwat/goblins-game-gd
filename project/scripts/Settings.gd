extends Node

const CONFIG_DIR: = "user://" 
const CONFIG_FILE_NAME: = "settings.cfg"

var configFile = ConfigFile.new()

func _init():
	configFile = configFile.load(CONFIG_DIR + CONFIG_FILE_NAME)

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

func save_settings()->void:
	save_settings_resource()
	#save_settings_JSON()

func load_settings()->void:
	if configFile == 7: # file not created
		save_settings()
	
func save_settings_resource() -> void:
	var new_save: = SaveSettings.new()
	new_save.inputs = SettingsControls.get_input_data()
	
	#configFile.save(CONFIG_DIR + CONFIG_FILE_NAME, new_save)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
