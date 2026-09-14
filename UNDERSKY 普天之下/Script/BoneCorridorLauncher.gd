# BoneCorridorLauncher.gd
extends AttackLauncher

#region：配置参数
func _ready() -> void:
	config = {
		"start_x": 0.0,
		"start_y": 0.0,
		"count": 10,
		"space_x": 10.0,
		"space_h": 100.0,
		"speed": 5.0,
		"angle": 0.0,
		"wave_amplitude": 0.0,
		"wave_frequency": 1.0,
		"wave_offset": 0.0
	}
#endregion：配置参数
