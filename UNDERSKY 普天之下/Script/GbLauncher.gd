# GbLauncher.gd
extends AttackLauncher

#region：配置参数
func _ready() -> void:
	config = {
		"start_x": 0.0,				# 龙骨炮的 x 坐标
		"start_y": 0.0,				# 龙骨炮的 y 坐标
		"angle": 0.0,				# 龙骨炮的发射角度
		"auto_aim": false,			# 是否自动瞄准玩家
		"delay": 1.0,				# 发射前等待的时间
		"last": 0.7,				# 发射时持续的时间
		"appear": 0.2,				# 发射前动画的时长
		"velocity": 20.0,			# 发射时退出的速度
		"size": 1.0,				# 龙骨炮放大的倍数
		"width": 30.0,				# 激光的宽度
		"pulse_amplitude": 0.15,	# 脉动幅度（宽度变化的相对值）
		"pulse_speed": 2.0			# 脉动速度（Hz）
	}
#endregion：配置参数
