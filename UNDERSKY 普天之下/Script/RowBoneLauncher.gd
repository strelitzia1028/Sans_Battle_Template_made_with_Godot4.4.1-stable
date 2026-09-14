# RowBoneLauncher.gd
extends AttackLauncher

#region：配置参数
func _ready() -> void:
	config = {
		"target_x": 0.0,
		"target_y": 20.0,
		"last": 0.3,
		"speed": 750.0,
		"width": 1.0,
		"angle": 0.0
	}
#endregion：配置参数
