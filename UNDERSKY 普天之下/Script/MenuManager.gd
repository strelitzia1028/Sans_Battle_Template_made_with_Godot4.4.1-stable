# MenuManager.gd
extends Node2D

#region：预加载
@export var border: AnimatableBody2D
@export var player: CharacterBody2D
@export var sans: CharacterBody2D
@export var wave_manager: AnimationPlayer
@onready var node_fight = $FIGHT
@onready var node_act = $ACT
@onready var node_item = $ITEM
@onready var node_mercy = $MERCY
@onready var judger = $Target/Judger
@onready var miss_ani = $Target/MISS
@onready var bag = $Bag
@onready var other_options = $OtherOptions
@onready var dialogue_box = $DialogueBox
@onready var select_menu_audio = $SelectMenu
@onready var heal_audio = $Heal
#endregion：预加载

#region：子菜单类 和 菜单状态参数
class SubMenu:
	var name: String
	var position: Vector2
	var offset: Vector2
	var node: Node
	
	func _init(name, position, offset, node):
		self.name = name
		self.position = position
		self.offset = offset
		self.node = node

var submenus: Array[SubMenu] = []

enum MenuState {MAIN, FIGHT, ACT, ITEM, MERCY, DIALOGUE}
var current_menu_state: MenuState = MenuState.MAIN
var recorded_state: MenuState = MenuState.MAIN
var current_selection_index: int = 0
var recorded_index: int = 0
var state_timer: float = 0.0
#endregion：子菜单类 和 菜单状态参数

#region：初始化 和 主函数
func _ready() -> void:
	_initialize_menus()
	_update_menu_state()

## 初始化菜单
func _initialize_menus():
	Global.menu_or_not = false
	var fight = SubMenu.new("FIGHT", Vector2(-274.5, 235.0), Vector2(0.0, 0.0), node_fight)
	var act = SubMenu.new("ACT", Vector2(-91.5, 235.0), Vector2(-1.0, 0.0), node_act)
	var item = SubMenu.new("ITEM", Vector2(91.5, 235.0), Vector2(0.0, 0.0), node_item)
	var mercy = SubMenu.new("MERCY", Vector2(274.5, 235.0), Vector2(1.0, 0.0), node_mercy)
	for i in [fight, act, item, mercy]:
		submenus.append(i)

func _process(delta: float) -> void:
	if Global.menu_or_not:
		_handle_input()
		state_timer += delta
#endregion：初始化 和 主函数

#region：菜单模式相关函数
## 进入菜单模式
func enter_menu_mode():
	dialogue_box.clear_all_dialogue()
	border.set_process_state(false)
	border.type = border.Type.MID
	Global.menu_or_not = true
	current_menu_state = MenuState.MAIN
	recorded_state = MenuState.MAIN
	state_timer = 0.0
	player.visible = true
	current_selection_index = 0
	_update_menu_state()

## 退出菜单模式
func exit_menu_mode():
	dialogue_box.clear_all_dialogue()
	border.type = border.Type.SMALL
	if border.border_zs_instant == border.border_zs:
		border.set_process_state(false)
	Global.menu_or_not = false
	current_menu_state = MenuState.MAIN
	recorded_state = MenuState.MAIN
	state_timer = 0.0
	player.visible = true
	_update_menu_state()
	bag.update_labels()
	for submenu in submenus:
		submenu.node.play("0")
	
	player.position = Vector2(0.0, 50.0)
	if player.spr.texture == player.spr_red:
		player.move_mode = player.MoveMode.RED
	else:
		player.move_mode = player.MoveMode.BLUE
	
	wave_manager.next_round()

## 更新菜单状态
func _update_menu_state():
	## 调试用
	#print(current_selection_index)
	if Global.menu_or_not:
		match current_menu_state:
			MenuState.MAIN:
				for submenu in submenus:
					submenu.node.play("0")
				submenus[current_selection_index].node.play("1")
#endregion：菜单模式相关函数

#region：输入处理相关函数
## 处理输入
func _handle_input():
	if Input.is_action_just_pressed("left"):
		handle_left_input()
	elif Input.is_action_just_pressed("right"):
		handle_right_input()
	elif Input.is_action_just_pressed("up"):
		handle_up_input()
	elif Input.is_action_just_pressed("down"):
		handle_down_input()
	elif Input.is_action_just_pressed("select"):
		handle_select_input()
	elif Input.is_action_just_pressed("back"):
		handle_back_input()

func handle_left_input():
	match current_menu_state:
		MenuState.MAIN:
			var original_index = current_selection_index
			current_selection_index = wrapi(current_selection_index - 1, 0, submenus.size())
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
		
		MenuState.ITEM:
			var original_index = current_selection_index
			current_selection_index = wrapi(current_selection_index - 1, 0, bag.items.size())
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
	_update_menu_state()

func handle_right_input():
	match current_menu_state:
		MenuState.MAIN:
			var original_index = current_selection_index
			current_selection_index = wrapi(current_selection_index + 1, 0, submenus.size())
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
		
		MenuState.ITEM:
			var original_index = current_selection_index
			current_selection_index = wrapi(current_selection_index + 1, 0, bag.items.size())
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
	_update_menu_state()

func handle_up_input():
	match current_menu_state:
		MenuState.ITEM:
			var original_index = current_selection_index
			# 计算当前物品所在的列
			var current_column = current_selection_index % bag.columns.size()
			# 尝试移动到上一行同一列
			var new_index = current_selection_index - bag.columns.size()
			# 确保新索引在有效范围内且在同一列
			if new_index >= 0 and (new_index % bag.columns.size() == current_column):
				current_selection_index = new_index
			# 如果无法垂直移动，则循环到该列的底部
			else:
				# 计算该列的最后一个物品索引
				var last_in_column = current_column
				while last_in_column + bag.columns.size() < bag.items.size():
					last_in_column += bag.columns.size()
				
				# 确保计算出的索引有效
				if last_in_column < bag.items.size() \
				and (last_in_column % bag.columns.size() == current_column):
					current_selection_index = last_in_column
				
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
	_update_menu_state()

func handle_down_input():
	match current_menu_state:
		MenuState.ITEM:
			var original_index = current_selection_index
			# 计算当前物品所在的列
			var current_column = current_selection_index % bag.columns.size()
			# 尝试移动到下一行同一列
			var new_index = current_selection_index + bag.columns.size()
			# 确保新索引在有效范围内且在同一列
			if new_index < bag.items.size() \
			and (new_index % bag.columns.size() == current_column):
				current_selection_index = new_index
			# 如果无法垂直移动，则循环到该列的顶部
			else:
				var first_in_column = current_column
				if first_in_column < bag.items.size():
					current_selection_index = first_in_column
				
			if current_selection_index != original_index:
				select_menu_audio.play(0.0)
	_update_menu_state()

func handle_select_input():
	match current_menu_state:
		MenuState.MAIN:
			select_menu_audio.play(0.0)
			recorded_index = current_selection_index
			recorded_state = current_menu_state
			match current_selection_index:
				0:	# 进入 FIGHT 子菜单
					current_selection_index = 0
					current_menu_state = MenuState.FIGHT
					state_timer = 0.0
					recorded_state = current_menu_state
					judger.current_state = judger.State.START
					judger.sans_can_miss = true
				
				1:	# 进入 ACT 子菜单
					current_selection_index = 0
					current_menu_state = MenuState.ACT
					state_timer = 0.0
					recorded_state = current_menu_state
					other_options.update_labels()
				
				2:	# 进入 ITEM 子菜单
					if bag.items.size() > 0:
						current_selection_index = 0
						current_menu_state = MenuState.ITEM
						state_timer = 0.0
						recorded_state = current_menu_state
						bag.update_labels()
					else:
						dialogue_box.show_text("没有东西可以使用了……")
						player.visible = false
						current_menu_state = MenuState.DIALOGUE
						state_timer = 0.0
				
				3:	# 进入 MERCY 子菜单
					current_selection_index = 0
					current_menu_state = MenuState.MERCY
					state_timer = 0.0
					recorded_state = current_menu_state
					other_options.update_labels()
		
		MenuState.FIGHT:
			judger.can_stop_move = true
			# 此处的 player.visible = false 放在 TargetJudger.gd 中完成，有利于在阅读 TargetJudger.gd 时形成逻辑闭环
			# 此处的 state_timer = 0.0 放在 TargetJudger.gd 中完成，从而确保玩家必须看完动画
		
		MenuState.ACT:
			select_menu_audio.play(0.0)
			player.visible = false
			other_options.use_option(other_options.get_option_index())
			current_menu_state = MenuState.DIALOGUE
			state_timer = 0.0
			other_options.update_labels()
		
		MenuState.ITEM:
			select_menu_audio.play(0.0)
			heal_audio.play(0.0)
			player.visible = false
			bag.use_item(current_selection_index)
			if current_selection_index >= bag.items.size():
				current_selection_index -= 1
			elif current_selection_index <= 0:
				current_selection_index = 0
			current_menu_state = MenuState.DIALOGUE
			state_timer = 0.0
			bag.update_labels()
		
		MenuState.MERCY:
			select_menu_audio.play(0.0)
			player.visible = false
			other_options.use_option(other_options.get_option_index())
			current_menu_state = MenuState.DIALOGUE
			state_timer = 0.0
			other_options.update_labels()
		
		MenuState.DIALOGUE:
			if state_timer >= 0.3:
				select_menu_audio.play(0.0)
				if dialogue_box.is_complete_current_dialogue():
					match recorded_state:
						MenuState.MAIN:
							current_selection_index = recorded_index
							# 提前设置角色坐标，防止闪现
							player.position = submenus[current_selection_index].position + Vector2(-38.0, 0.0)
							current_menu_state = MenuState.MAIN
							dialogue_box.clear_last_dialogue()
							player.visible = true
						
						MenuState.FIGHT:
							# 确保动画完成，避免玩家跳过动画
							if judger.current_state == judger.State.IDLE:
								exit_menu_mode()
								player.visible = true
						
						MenuState.ACT, MenuState.ITEM, MenuState.MERCY:
							exit_menu_mode()
							player.visible = true
				else:
					dialogue_box.complete_current_dialogue()
	_update_menu_state()

func handle_back_input():
	match current_menu_state:
		MenuState.FIGHT, MenuState.ACT, MenuState.ITEM, MenuState.MERCY:
			select_menu_audio.play(0.0)
			current_selection_index = recorded_index
			current_menu_state = MenuState.MAIN
	_update_menu_state()
	bag.update_labels()
	other_options.update_labels()
#endregion：输入处理相关函数

#region：获取当前索引所代表的坐标
func get_menu_position() -> Vector2:
	match current_menu_state:
		MenuState.MAIN:
			return submenus[current_selection_index].position + Vector2(-38.0, 25.0)
		
		MenuState.ITEM:
			if bag.items.size() > 0:
				return bag.items[current_selection_index].label.position + Vector2(-15.0, 10.0)
			else:
				current_selection_index = recorded_index
				current_menu_state = MenuState.MAIN
				return submenus[2].position + Vector2(-38.0, 0.0)
		
		MenuState.ACT, MenuState.MERCY:
			return other_options.options[current_selection_index].label.position + Vector2(-15.0, 10.0)
	
	return Vector2(0.0, 50.0)
#endregion：获取当前索引所代表的坐标
