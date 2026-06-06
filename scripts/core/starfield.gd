class_name Starfield
extends MultiMeshInstance3D

const STAR_COUNT: int = 2800
const SPHERE_RADIUS: float = 480.0
const STAR_SIZE_MIN: float = 1.2
const STAR_SIZE_MAX: float = 3.8

const STAR_PALETTE: Array[Color] = [
	Color(0.95, 0.95, 1.0),
	Color(0.75, 0.85, 1.0),
	Color(0.85, 0.7, 1.0),
	Color(0.6, 0.95, 1.0),
	Color(1.0, 0.85, 0.75),
]


func _ready() -> void:
	_generate_stars()


func _generate_stars() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = STAR_COUNT
	mm.mesh = _create_quad_mesh()

	for i in STAR_COUNT:
		var dir := Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()

		var pos := dir * SPHERE_RADIUS
		var size := randf_range(STAR_SIZE_MIN, STAR_SIZE_MAX)
		var tint: Color = STAR_PALETTE[randi() % STAR_PALETTE.size()]
		var brightness := randf_range(0.55, 1.0)
		var color := Color(
			tint.r * brightness,
			tint.g * brightness,
			tint.b * brightness
		)

		var t := Transform3D()
		t = t.scaled(Vector3(size, size, size))
		t.origin = pos

		mm.set_instance_transform(i, t)
		mm.set_instance_color(i, color)

	multimesh = mm


func _create_quad_mesh() -> QuadMesh:
	var quad := QuadMesh.new()
	quad.size = Vector2(1.0, 1.0)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.surface_set_material(0, mat)
	return quad
