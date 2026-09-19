extends CharacterBody3D

# إعدادات الحركة لـ "جالوب - Gallop"
var gallop_speed = 10.0  # سرعة الجري للأمام
var strafe_speed = 5.0  # سرعة الحركة الجانبية
var jump_force = 6.0  # قوة القفز
var gravity = 9.8  # الجاذبية

var vertical_velocity = 0.0


func _physics_process(delta):
	# 1. حساب الجاذبية
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0

	# 2. إدخال المستخدم للحركة الجانبية (يمين/يسار)
	var horizontal_input = Input.get_axis("ui_left", "ui_right")
	var horizontal_velocity = horizontal_input * strafe_speed

	# 3. إدخال المستخدم للقفز
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):  # افترض Space للقفز
		vertical_velocity = jump_force

	# 4. تجميع السرعات
	velocity.x = horizontal_velocity
	velocity.y = vertical_velocity
	velocity.z = gallop_speed

	# 5. تحريك الكائن وتطبيق الفيزياء
	move_and_slide()
