# AttackLauncher.gd
extends Node2D
class_name AttackLauncher

#region：预加载
@onready var object_pool = $ObjectPool
#endregion：预加载

#region：配置参数
@export var config: Dictionary = {}
#endregion：配置参数

#region：初始化
func _ready():
	randomize()
#endregion：初始化

#region：召唤对象
## 清除所有对象
func clear_all():
	object_pool.clear_pool()

## 召唤对象
func spawn():
	# 从对象池获取实例
	var obj = object_pool.get_object()
	if not obj:
		return
	
	# 初始化并启动
	obj.init(config)
	obj.start_attack()
#endregion：召唤对象
