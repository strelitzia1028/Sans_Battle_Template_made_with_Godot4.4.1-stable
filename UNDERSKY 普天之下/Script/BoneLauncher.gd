# BoneLauncher.gd
extends AttackLauncher

#region：配置参数
func _ready() -> void:
	config = {
		"start_x": 0.0,
		"start_y": 0.0,
		"type": "white",
		"height": 5,
		"x_velocity": 100.0,
		"y_velocity": 0.0,
		"width": 1.0,
		"angle": 0.0,
		"is_managed_by_parent": false
	}
#endregion：配置参数
