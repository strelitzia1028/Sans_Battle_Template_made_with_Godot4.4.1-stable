# BoneWall.gd
extends ObjectPoolSupport

@onready var warn = $Warn
@onready var bone = $Bone
@onready var attack_audio = $AttackAudio

var target_x: float
var target_y: float
var last: float
var speed: float
var width: float
var angle: float
var target_position: Vector2
var back_position: Vector2
var attack_audio_can_play = true
var color: Array[Color] = [Color.RED, Color.YELLOW, Color.GREEN]
enum State {IDLE, WARN, MOVE, BACK}
var state: State = State.IDLE
var state_timer: float = 0.0

func init(config: Dictionary) -> void:
	target_x = config.get("target_x")
	target_y = config.get("target_y")
	last = config.get("last")
	speed = config.get("speed")
	width = config.get("width")
	angle = config.get("angle")
	
	target_position = Vector2(target_x, target_y) + Vector2(0, 51)
	back_position = target_position + Vector2(0, 200)
	velocity = Vector2.ZERO
	rotation = deg_to_rad(angle)
	global_position = back_position.rotated(rotation)
	scale.x = width
	state = State.IDLE
	visible = false
	warn.visible = false
	attack_audio_can_play = true
	state_timer = 0.0

func _physics_process(delta: float) -> void:
	state_timer += delta
	match state:
		State.WARN:
			const STEP = 0.05			# 每色停留时间
			const TOTAL = 9 * STEP		# 3 * 3 共 9 步
			warn.global_position = target_position
			warn.visible = true
			
			var frame = int(state_timer / STEP)
			var i = frame / 3
			var j = frame % 3
			warn.default_color = color[j]
			if state_timer >= TOTAL:
				warn.visible = false
				state = State.MOVE
				state_timer = 0.0
		
		State.MOVE:
			if attack_audio_can_play:
				attack_audio.play(0.0)
				attack_audio_can_play = false
			# 移动逻辑
			if global_position != target_position:
				# 应用旋转后的速度
				global_position = global_position.move_toward(target_position, speed * delta)
				state_timer = 0.0
			else:
				if state_timer >= last:
					state = State.BACK
					state_timer = 0.0
		
		State.BACK:
			velocity = Vector2.DOWN.rotated(rotation) * speed
			if not is_in_camera_view(100):
				state = State.IDLE
				state_timer = 0.0
				return_to_pool()
	move_and_slide()

#region：对象池支持部分重写
## 重置状态（用于对象池）
func reset():
	# 重置状态
	state_timer = 0.0
	visible = false
	velocity = Vector2.ZERO
	attack_audio_can_play = true
#endregion：对象池支持部分重写

#region：外部调用开始攻击
func start_attack():
	attack_audio_can_play = true
	state = State.WARN
	visible = true
#endregion：外部调用开始攻击
