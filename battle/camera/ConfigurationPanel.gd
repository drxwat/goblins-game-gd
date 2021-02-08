extends Node

export(NodePath) var camera_controller_path

var camera_controller

onready var movement_speed_label = $MovementSpeedLabel
onready var movement_damping_label = $MovementDampingLabel
onready var zoom_sensibility_label = $ZoomSensibilityLabel
onready var rotation_sensibility_label = $RotationSensibilityLabel

onready var movement_speed_slider = $MovementSpeed
onready var movement_damping_slider = $MovementDamping
onready var zoom_sensibility_slider = $ZoomSensibility
onready var rotation_sensibility_slider = $RotationSensibility

func _ready():
	camera_controller = get_node(camera_controller_path)
	
	set_movement_speed_text(camera_controller.movement_speed)
	movement_speed_slider.value = camera_controller.movement_speed
	movement_speed_slider.connect("value_changed",self,"change_movement_speed")
	
	set_movement_damping_text(camera_controller.movement_damping)
	movement_damping_slider.value = camera_controller.movement_damping
	movement_damping_slider.connect("value_changed",self,"change_movement_damping")
	
	set_zoom_sensibility_text(camera_controller.zoom_sensibility)
	zoom_sensibility_slider.value = camera_controller.zoom_sensibility
	zoom_sensibility_slider.connect("value_changed",self,"change_zoom_sensibility")
	
	set_rotation_sensibility_text(camera_controller.rotation_sensibility)
	rotation_sensibility_slider.value = camera_controller.rotation_sensibility
	rotation_sensibility_slider.connect("value_changed",self,"change_rotation_sensibility")
	
func change_movement_speed(value : float):
	camera_controller.movement_speed = value
	set_movement_speed_text(value)
	
func change_movement_damping(value : float):
	camera_controller.movement_damping = value
	set_movement_damping_text(value)
	
func change_zoom_sensibility(value : float):
	camera_controller.zoom_sensibility = value
	set_zoom_sensibility_text(value)
	
func change_rotation_sensibility(value : float):
	camera_controller.rotation_sensibility = value
	set_rotation_sensibility_text(value)

func set_movement_speed_text(value : float):
	movement_speed_label.text = "Movement Speed: %s" % value
func set_movement_damping_text(value : float):
	movement_damping_label.text = "Movement Damping: %s" % value
func set_zoom_sensibility_text(value : float):
	zoom_sensibility_label.text = "Zoom Sensibility: %s" % value
func set_rotation_sensibility_text(value : float):
	rotation_sensibility_label.text = "Rotation Sensibility: %s" % value
