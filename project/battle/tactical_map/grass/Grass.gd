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

var mesh_rid: RID
var material = preload("res://assets/battle/grass/Grass.material").get_rid()

func _ready():
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
	
	VisualServer.multimesh_allocate(multimesh, get_count(), VisualServer.MULTIMESH_TRANSFORM_3D, VisualServer.MULTIMESH_COLOR_NONE, VisualServer.MULTIMESH_CUSTOM_DATA_FLOAT)
	
	mesh_rid = rid_blade_mesh()
	VisualServer.multimesh_set_mesh(multimesh, mesh_rid)
	
	var bpt = get_count() / thread_count  # blades per thread
	threads = []
	for t in thread_count:
		threads.append(Thread.new())
		threads[t].start(self, "thread_worker", [multimesh, bpt * t, bpt * t + bpt])
	
	for t in thread_count:
		threads[t].wait_to_finish()
	
#	for i in get_count():
#		setup_blade(multimesh, i)
	
	var instance = VisualServer.instance_create()
	var scenario = get_world().scenario
	
	VisualServer.instance_set_scenario(instance, scenario)
	VisualServer.instance_set_base(instance, multimesh)
	
	VisualServer.instance_geometry_set_material_override(instance, material)

func thread_worker(data: Array):
	var rid = data[0]
	var start = data[1]
	var stop = data[2]
	
	for i in range(start, stop):
		setup_blade(rid, i)

func setup_blade(rid: RID, i: int):
	var width = rand_range(blade_width.x, blade_width.y)
	var height = rand_range(blade_height.x, blade_height.y)
	
	var position: Vector2
	while true:
		position = Vector2(rand_range(-area.x/2.0, area.x/2.0), rand_range(-area.y/2.0, area.y/2.0))
		if get_parent().is_grass_soil(Vector3(position.x, 0, position.y)):
			break
		
	var rotation = rand_range(blade_rotation.x, blade_rotation.y)
	
	var sway_yaw = rand_range(blade_sway_yaw.x, blade_sway_yaw.y)
	var sway_pitch = rand_range(blade_sway_pitch.x, blade_sway_pitch.y)
	
	var transform = Transform.IDENTITY
	transform.origin = Vector3(position.x, 0, position.y)
	transform.basis = Basis.IDENTITY.rotated(Vector3.UP, deg2rad(rotation))
	
	VisualServer.multimesh_instance_set_transform(rid, i, transform)
	VisualServer.multimesh_instance_set_custom_data(rid, i, Color(width, height, deg2rad(sway_pitch), deg2rad(sway_yaw)))

func get_count():
	if Engine.editor_hint:
		return editor_count
	else:
		return game_count
