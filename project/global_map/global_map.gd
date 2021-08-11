extends Node2D


const TICK_TIME = 5

onready var player: Node2D = get_node("Player")
onready var tile_map: GlobalTileMap = get_node("GlobalTileMap")
onready var units_parent = get_node("Units");
onready var GlobalMapUI = $"CanvasLayer/GlobalMapUI"
onready var city_manager := CitiesManager.new(tile_map, 0)


var rng = RandomNumberGenerator.new()
var time_to_next_tick = TICK_TIME


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	rng.randomize()
	player.connect("contacted_enemy", GlobalMapUI, "_on_contacted_enemy")
	__DEBUG_cities_path_routes()
	

func _process(delta):
	time_to_next_tick -= delta
	if time_to_next_tick < 0:
		time_to_next_tick = TICK_TIME
		_tick_cities()

func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	player.set_target(get_global_mouse_position())


func _tick_cities():
	print("TICK")
	for city_id in city_manager.cities:
		var city: City = city_manager.cities[city_id]
		yield(get_tree().create_timer(0.2), "timeout")
		city.tick()


func __DEBUG_cities_path_routes():
	if not GlobalConstants.DEBUG_CITIES_ROUTES: 
		return
	var visited_cities_ids = {}
	for city_id in city_manager.cities:
		var color = Color(rng.randf(), rng.randf(), rng.randf())
		visited_cities_ids[city_id] = true
		var city: City = city_manager.cities[city_id]
		for other_city_meta in city.other_cities:
			var path_to_city = other_city_meta[0]
			var other_city: City = other_city_meta[1]
			if visited_cities_ids.has(other_city.id):
				continue
			var route_line = Line2D.new()
			route_line.width = 10
			route_line.default_color = color
			route_line.name = "Route from city %s to city %s" % [city.id, other_city.id]
			route_line.points = path_to_city
			route_line.position = Vector2(0, (city_id * 25) - 100)
			add_child(route_line)
