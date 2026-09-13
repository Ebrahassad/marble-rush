extends StaticBody3D

func _ready() -> void:
	var theme_data: Dictionary = ThemeManager.get_current_theme()
	var track_material := StandardMaterial3D.new()
	track_material.albedo_color = theme_data.track_color
	track_material.metallic = 0.4
	track_material.roughness = 0.5
	_apply_material_recursive(self, track_material)

func _apply_material_recursive(node: Node, mat: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, mat)
	for child in node.get_children():
		_apply_material_recursive(child, mat)
