extends Node3D

@export var spin_speed: Vector2 = Vector2(0.6, 0.9)

func _process(delta: float) -> void:
	rotate_x(spin_speed.x * delta)
	rotate_y(spin_speed.y * delta)
