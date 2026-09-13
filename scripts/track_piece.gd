extends StaticBody3D

func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.08, 0.27)
	mat.metallic = 0.4
	mat.roughness = 0.5
	_apply_material_recursive(self, mat)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_material_recursive(child, mat)
