# EventManager.gd
extends Node2D
class_name EventManager

#region：预加载
@export var sans: CharacterBody2D
@export var border: AnimatableBody2D
@onready var gb_launcher = $GbLauncher
@onready var bone_launcher = $BoneLauncher
@onready var bone_wall_launcher = $BoneWallLauncher
@onready var bone_corridor_launcher = $BoneCorridorLauncher
@onready var sans_dialogue_box: DialogueBox
#endregion：预加载

#region：攻击调用
func _ready():
	sans_dialogue_box = sans.get_node("SansDialogueBox")

func trigger_screen_flash():
	get_tree().call_group("screen_flash", "screen_flash")

func trigger_clean_gaster_blaster():
	gb_launcher.clear_all()

func trigger_clean_bone():
	bone_launcher.clear_all()

func trigger_clean_bone_wall():
	bone_wall_launcher.clear_all()

func trigger_clean_bone_corridor():
	bone_corridor_launcher.clear_all()

func trigger_clean_all():
	gb_launcher.clear_all()
	bone_launcher.clear_all()
	bone_wall_launcher.clear_all()
	bone_corridor_launcher.clear_all()

func trigger_border_change(type: String = "small"):
	border.set_process_state(true)
	match type:
		"small":
			border.type = border.Type.SMALL
		"mid":
			border.type = border.Type.MID
		"large":
			border.type = border.Type.LARGE

## 触发对话事件
func trigger_dialogue(	text: String = "Default Text",
						text_offset: Vector2 = Vector2(-40.0, -10.0),
						clear_last: bool = true,
						show_per_char_time: float = 0.05,
						font_size_of_text: int = 20,
						label_rotation: float = 0.0,
						font_of_text: Resource = preload("res://Font/DTM-Sans.otf")	):
	Global.is_sans_talking = true
	sans_dialogue_box.show_sans_text(text, text_offset, clear_last, 
									show_per_char_time, font_size_of_text, 
									label_rotation, font_of_text)

## 触发骨头事件
func trigger_bone(	pos: Vector2 = Vector2.ZERO,
					type: String = "white",
					height: int = 1,
					velocity: Vector2 = Vector2(100.0, 0.0),
					width: float = 1.0,
					angle: float = 0.0,
					is_managed_by_parent: bool = false	):
	bone_launcher.config["start_x"] = to_global(pos).x
	bone_launcher.config["start_y"] = to_global(pos).y
	bone_launcher.config["type"] = type
	bone_launcher.config["height"] = height
	bone_launcher.config["x_velocity"] = velocity.x
	bone_launcher.config["y_velocity"] = velocity.y
	bone_launcher.config["width"] = width
	bone_launcher.config["angle"] = angle
	bone_launcher.config["is_managed_by_parent"] = is_managed_by_parent
	bone_launcher.spawn()

## 触发骨头事件
func trigger_bone_wall(	target: Vector2 = Vector2(0, 20),
						last: float = 0.3,
						speed: float = 750,
						width: float = 1.0,
						angle: float = 0.0	):
	bone_wall_launcher.config["target_x"] = to_global(target).x
	bone_wall_launcher.config["target_y"] = to_global(target).y
	bone_wall_launcher.config["last"] = last
	bone_wall_launcher.config["speed"] = speed
	bone_wall_launcher.config["width"] = width
	bone_wall_launcher.config["angle"] = angle
	bone_wall_launcher.spawn()

## 触发骨头长廊事件
func trigger_bone_corridor(	start_x: float = 0.0,
							start_y: float = 0.0,
							count: int = 10,
							space_x: float = 10.0,
							space_h: float = 100.0,
							speed: float = 5.0,
							angle: float = 0.0,
							wave_amplitude: float = 0.0,
							wave_frequency: float = 1.0,
							wave_offset: float = 0.0	):
	bone_corridor_launcher.config["start_x"] = start_x
	bone_corridor_launcher.config["start_y"] = start_y
	bone_corridor_launcher.config["count"] = count
	bone_corridor_launcher.config["space_x"] = space_x
	bone_corridor_launcher.config["space_h"] = space_h
	bone_corridor_launcher.config["speed"] = speed
	bone_corridor_launcher.config["angle"] = angle
	bone_corridor_launcher.config["wave_amplitude"] = wave_amplitude
	bone_corridor_launcher.config["wave_frequency"] = wave_frequency
	bone_corridor_launcher.config["wave_offset"] = wave_offset
	bone_corridor_launcher.spawn()

## 触发龙骨炮事件
func trigger_gaster_blaster(pos: Vector2 = Vector2.ZERO,
							angle: float = 0.0,
							auto_aim: bool = false,
							delay: float = 1.0,
							last:float = 0.7,
							appear: float = 0.2,
							velocity: float = 20.0,
							size: float = 1.0,
							width: float = 30.0,
							pulse_amplitude: float = 0.15,
							pulse_speed: float = 2.0):
	gb_launcher.config["start_x"] = to_global(pos).x
	gb_launcher.config["start_y"] = to_global(pos).y
	gb_launcher.config["angle"] = angle
	gb_launcher.config["auto_aim"] = auto_aim
	gb_launcher.config["delay"] = delay
	gb_launcher.config["last"] = last
	gb_launcher.config["appear"] = appear
	gb_launcher.config["velocity"] = velocity
	gb_launcher.config["size"] = size
	gb_launcher.config["width"] = width
	gb_launcher.config["pulse_amplitude"] = pulse_amplitude
	gb_launcher.config["pulse_speed"] = pulse_speed
	gb_launcher.spawn()

## 触发重力事件（0 度代表向下，90 度代表向左）
func trigger_gravity(direction: String = "down", dominate_mode: bool = false):
	match direction:
		"down":
			Global.player_node.rotate_gravity(0, dominate_mode)
		
		"up":
			Global.player_node.rotate_gravity(180, dominate_mode)
		
		"left":
			Global.player_node.rotate_gravity(90, dominate_mode)
		
		"right":
			Global.player_node.rotate_gravity(-90, dominate_mode)

## 触发 heart 切换事件
func trigger_heart(state: String = "red"):
	match state:
		"red":
			Global.player_node.enter_red_mode()
		
		"blue":
			Global.player_node.enter_blue_mode()
		
		"menu":
			Global.player_node.enter_menu_mode()
#endregion：攻击调用

#region：召唤按钮
func _on_emit_pressed() -> void:
	# 随机位置（在召唤半径内）
	var spawn_radius: float = 200.0		## 召唤半径
	var spawn_pos = global_position + Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	var spawn_angle = randf_range(-180.0,180.0)
	
	gb_launcher.config["start_x"] = spawn_pos.x
	gb_launcher.config["start_y"] = spawn_pos.y
	gb_launcher.config["angle"] = 0.0
	gb_launcher.config["auto_aim"] = true
	gb_launcher.config["size"] = 1
	gb_launcher.config["width"] = 30.0
	gb_launcher.spawn()

func _on_spawn_pressed() -> void:
	bone_launcher.config["start_x"] = Global.player_node.position.x - 200
	bone_launcher.config["start_y"] = Global.player_node.position.y
	bone_launcher.config["type"] = "white"
	bone_launcher.spawn()

func _on_spawn_blue_pressed() -> void:
	bone_launcher.config["type"] = "blue"
	bone_launcher.spawn()

func _on_spawn_orange_pressed() -> void:
	bone_launcher.config["type"] = "orange"
	bone_launcher.spawn()

func _on_row_bone_pressed() -> void:
	bone_wall_launcher.config["angle"] = 45
	bone_wall_launcher.spawn()

func _on_clear_pressed() -> void:
	trigger_clean_all()

func _on_corridor_pressed() -> void:
	trigger_bone_corridor(-125.0, 50.0, 50, 10.0, 30.0, 150.0, 0.0, 50.0, 2.5, 0.0)
#endregion：召唤按钮
