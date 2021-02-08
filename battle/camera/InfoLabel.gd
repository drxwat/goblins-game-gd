extends Label

export(NodePath) var target_path

var target_spatial

func _ready():
	target_spatial = get_node(target_path)

func _process(delta):
	text = """FPS: %s""" % [
				ceil(1/delta)
				]
