extends MeshInstance
class_name PathDot
enum PathDotColor { WHITE, GREEN, YELLOW, RED }

var colorMap = {
	PathDotColor.WHITE: Color('ffffff'),
	PathDotColor.GREEN: Color('35d900'),
	PathDotColor.YELLOW: Color('d7d900'),
	PathDotColor.RED: Color('d92e00')
}

func destroy(body: BattleUnit):
	queue_free()

func set_path_color(color: int):
	get_active_material(0).albedo_color = colorMap[color]
