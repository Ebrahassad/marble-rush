extends StaticBody3D

static var cached_material: StandardMaterial3D = null

func _ready() -> void:
	if cached_material == null:
		cached_material = StandardMaterial3D.new()
		cached_material.albedo_color = Color(0.36, 0.24, 0.14)
		cached_material.metallic = 0.0
		cached_material.roughness = 0.95
	_apply_material_recursive($Model, cached_material)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_material_recursive(child, mat)
