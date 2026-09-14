# HurtBox.gd
extends Area2D
class_name HurtBox

#region：伤害效果支持
@onready var hurt_audio = $HurtAudio
var _hurt_tick: int = 0						## 帧计数器
const HURT_INTERVAL: int = 2					## 每 n 个物理受伤一次
@export var type: String = "white"			## 伤害类型
@export var dmg: int = 0						## 基础伤害
@export var kr: int = 0						## 基础毒伤
@export var dmg_after_first_hit: int = 1		## 首次击中后的伤害
@export var kr_after_first_hit: int = 1		## 首次击中后的毒伤
var initial_type: String
var initial_dmg: int
var initial_kr: int
var initial_hp: int
var _first_hit_done: bool = false			## 首次攻击伤害结算完毕

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	set_process(false)
	_hurt_tick = 0

func init(type: String):
	initial_hp = Global.hp
	initial_dmg = dmg
	initial_kr = kr
	initial_type = type
	_first_hit_done = false
	set_process(false)
	_hurt_tick = 0

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return
	
	# 首次伤害
	if not _first_hit_done:
		damage_settlement()
		if Global.hp != initial_hp:
			_first_hit_done = true
			print("first hit done!")
			hurt_audio.play(0.0)
		# 立即改为 1 点帧伤
		dmg = 1
		kr  = 1
		# 启动每帧扣血
		set_process(true)

func _on_area_exited(area: Area2D):
	if area.is_in_group("player"):
		_first_hit_done = false
		set_process(false)

func _process(delta: float):
	_hurt_tick += 1
	if _hurt_tick % HURT_INTERVAL != 0:
		return
	damage_settlement()

## 伤害结算
func damage_settlement():
	var is_moving: bool = Global.player_node.velocity.length() > 0
	match initial_type:
		"blue":
			dmg = dmg * int(is_moving)
			kr = kr * int(is_moving)
		
		"orange":
			dmg = dmg * (1 - int(is_moving))
			kr = kr * (1 - int(is_moving))
	
	if Global.hp > 1 or Global.kr == 0:
		Global.hp = max(Global.hp - dmg, 0)
		Global.kr = min(Global.kr + kr, Global.max_kr)
	elif Global.hp == 1 and Global.kr > 0:
		Global.kr = max(Global.kr - dmg, 0)
	elif Global.hp == 1 and Global.kr == 0:
		Global.hp = 0
	
	get_tree().call_group("hp", "_update")
	Global.player_node.check_death()
#endregion：伤害效果支持
