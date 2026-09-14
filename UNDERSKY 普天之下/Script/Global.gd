# Global.gd
extends Node2D

#region：全局加载 Player 节点
var player_node: CharacterBody2D = null
func register_player(player: CharacterBody2D):
	player_node = player
#endregion：全局加载 Player 节点

#region：全局加载变量
var hp: int = 100					## 血量
var max_hp: int = 100				## 最大血量
var kr: int = 0						## 毒伤
var max_kr: int = 40					## 最大毒伤
var kr_timer: float = 0.0			## 毒伤计时器
var menu_or_not: bool = false		## 是否处于菜单模式
var is_sans_talking: bool = false	## Sans 是否正在讲话
var is_screen_flashing: bool = false
var player_final_texture: Texture	## 角色死亡前的最终纹理
var player_final_position: Vector2	## 角色死亡前的最终位置
#endregion：全局加载变量
