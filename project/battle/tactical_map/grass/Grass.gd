extends Spatial

export var game_count: int
export var editor_count: int
export var area = Vector2(10, 10)
export var blade_height = Vector2(0.06, 0.08)
export var blade_width = Vector2(0.01, 0.02)
export var blade_rotation = Vector2(-180, 180)
export var blade_sway_yaw = Vector2(-0.175, 0.175)
export var blade_sway_pitch = Vector2(0, 0.175)

export var thread_count: int = 4
var threads = []

var multimesh_rid: RID
var mesh_rid: RID

var material = preload("res://assets/battle/grass/Grass.material").get_rid()

var grass_cells: Array
var grass_cell_size: Vector2
var amount_blade_in_cell: int


func _ready():
	pass


func generate():
	if multimesh_rid != null and mesh_rid != null:
		clear()
	rebuild()
	

func make_blade_mesh() -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	
	verts.push_back(Vector3(-0.5, 0.0, 0.0))
	verts.push_back(Vector3(0.5, 0.0, 0.0))
	verts.push_back(Vector3(0.0, 1.0, 0.0))
	
	uvs.push_back(Vector2(0.0, 0.0))
	uvs.push_back(Vector2(1.0, 0.0))
	uvs.push_back(Vector2(0.5, 1.0))
	
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	return mesh

func rid_blade_mesh() -> RID:
	var mesh = VisualServer.mesh_create()
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	
	verts.push_back(Vector3(-0.5, 0.0, 0.0))
	verts.push_back(Vector3(0.5, 0.0, 0.0))
	verts.push_back(Vector3(0.0, 1.0, 0.0))
	
	uvs.push_back(Vector2(0.0, 0.0))
	uvs.push_back(Vector2(1.0, 0.0))
	uvs.push_back(Vector2(0.5, 1.0))
	
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_TEX_UV] = uvs
	
	VisualServer.mesh_add_surface_from_arrays(mesh, Mesh.PRIMITIVE_TRIANGLES, arr)
	
	return mesh

func rebuild():
	var multimesh = VisualServer.multimesh_create()
	multimesh_rid = multimesh
	
	VisualServer.multimesh_allocate(multimesh, get_count(), VisualServer.MULTIMESH_TRANSFORM_3D, VisualServer.MULTIMESH_COLOR_NONE, VisualServer.MULTIMESH_CUSTOM_DATA_FLOAT)
	
	mesh_rid = rid_blade_mesh()
	VisualServer.multimesh_set_mesh(multimesh, mesh_rid)
	
#	var bpt = get_count() / thread_count  # blades per thread
	threads = []
	
	amount_blade_in_cell = get_parent()._amount_blade_in_cell
	grass_cell_size = get_parent().cell_size
	grass_cells = get_parent().get_global_coord_used_grass_cells()
	
	amount_blade_in_cell = 40
	
	var bpt = int(ceil(amount_blade_in_cell*grass_cells.size() / thread_count))
	var bpt_cell = int(ceil(grass_cells.size() / thread_count))
	
	bpt += 10000
	
	var bpt_remainder = int(ceil((amount_blade_in_cell*grass_cells.size()) % thread_count))
	var bpt_cell_remainder = int(ceil(grass_cells.size() % thread_count))
	
	var arg: Array
	var rng = RandomNumberGenerator.new()
	
	for t in thread_count:
		arg = [
			multimesh,
			bpt * t,
			bpt * t + bpt,
			bpt_cell * t,
			bpt_cell * t + bpt_cell,
			grass_cells, amount_blade_in_cell, grass_cell_size,
			rng
		]
		
		if t == (thread_count - 1):
			arg[2] += bpt_remainder
			arg[4] += bpt_cell_remainder
			
		
		threads.append(Thread.new())
		threads[t].start(self, "thread_worker", arg)
#			breakpoint
	
	for t in thread_count:
		threads[t].wait_to_finish()
		
	
	
	var instance = VisualServer.instance_create()
	var scenario = get_world().scenario
	
	VisualServer.instance_set_scenario(instance, scenario)
	VisualServer.instance_set_base(instance, multimesh)
	
	VisualServer.instance_geometry_set_material_override(instance, material)


func clear():
	VisualServer.free_rid(mesh_rid)
	VisualServer.free_rid(multimesh_rid)


func thread_worker(data: Array):
	var rid = data[0]
	var start = data[1]
	var stop = data[2]
	var start_cell = data[3]
	var stop_cell = data[4]
	var cells = data[5]
	var amount_blade_in_cell = data[6]
	var grass_cell_size: Vector2 = data[7]
	var rng = data[8]
	
	
	
	var checking: bool = false
	
	var cell_index: int = start_cell
	var cell_current_number_blades: int = 0
	
	var amount_available_cells = stop_cell - start_cell
	var amount_wishful_blades = amount_available_cells * amount_blade_in_cell
	var amount_available_blades = stop - start
	
#	if amount_wishful_blades <= amount_available_blades:
#		checking = true
#	else:
#		amount_blade_in_cell = amount_available_blades / amount_available_cells
	
	
	
	for i in range(start, stop):
		setup_blade(
			rid, i,
			cells[cell_index], grass_cell_size,
			rng
		)
		cell_current_number_blades += 1
		
		if cell_current_number_blades == amount_blade_in_cell:
			cell_current_number_blades = 0
			cell_index += 1
		
		
		if cell_index == stop_cell:
			break

func setup_blade(rid: RID, i: int,
cell_coord: Vector3, grass_cell_size: Vector2,
rng
):
	var width = rand_range(blade_width.x, blade_width.y)
	var height = rand_range(blade_height.x, blade_height.y)
	
	var x = grass_cell_size.x
	var y = grass_cell_size.y
	
	var rand_shift = Vector2(rng.randf_range(-x/2, x/2), rng.randf_range(-y/2, y/2))
	
	var position: Vector3
	position = cell_coord
	position += Vector3(rand_shift.x, 0, rand_shift.y)
	
	var rotation = rand_range(blade_rotation.x, blade_rotation.y)
	
	var sway_yaw = rand_range(blade_sway_yaw.x, blade_sway_yaw.y)
	var sway_pitch = rand_range(blade_sway_pitch.x, blade_sway_pitch.y)
	
	var transform = Transform.IDENTITY
	transform.origin = Vector3(position.x, 0, position.z)
	transform.basis = Basis.IDENTITY.rotated(Vector3.UP, deg2rad(rotation))
	
	VisualServer.multimesh_instance_set_transform(rid, i, transform)
	VisualServer.multimesh_instance_set_custom_data(rid, i, Color(width, height, deg2rad(sway_pitch), deg2rad(sway_yaw)))

func get_count():
	if Engine.editor_hint:
		return editor_count
	else:
		return game_count
