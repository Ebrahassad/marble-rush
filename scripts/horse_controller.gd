extends CharacterBody3D

@export var speed: float = 10.0
@export var jump_impulse: float = 8.5
@export var gravity: float = 22.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and is_on_floor():
		velocity.y = jump_impulse

	velocity.z = -speed

	move_and_slide()
