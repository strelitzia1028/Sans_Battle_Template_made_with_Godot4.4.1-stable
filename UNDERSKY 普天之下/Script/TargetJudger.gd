# TargetJudger.gd
extends CharacterBody2D

@export var menu_node: Node2D
@export var target: Node2D
@export var dialogue_box: Node2D
@export var player_attack: AnimatedSprite2D
@export var player_attack_audio: AudioStreamPlayer2D
@onready var line = $JudgmentLine
@onready var tween: Tween = null
@onready var sans: CharacterBody2D
@onready var miss_ani: AnimatedSprite2D

enum State {IDLE, START, MOVE, FLASH, END}
var current_state: State = State.IDLE
var state_timer: float = 0.0
var can_stop_move: bool = false
var sans_can_miss: bool = false

func _ready() -> void:
	target.scale = Vector2(0, 0)
	target.visible = false
	current_state = State.IDLE

func _physics_process(delta: float) -> void:
	if menu_node.recorded_state == menu_node.MenuState.FIGHT:
		move_and_slide()
		state_timer += delta
		
		match current_state:
			State.START:
				sans = get_parent().get_parent().sans
				miss_ani = get_parent().get_parent().miss_ani
				Global.player_node.visible = false
				position = Vector2(-270, 0)
				target.visible = true
				if tween and tween.is_running():
					tween.kill()
				
				var tween = create_tween()
				tween.set_ease(Tween.EASE_OUT_IN)	# 两端的插值最快
				tween.tween_property(target, "scale", Vector2(1, 1), 0.1)
				
				can_stop_move = false
				current_state = State.MOVE
				state_timer = 0.0
			
			State.MOVE:
				if state_timer >= 0.2:
					velocity = Vector2(450, 0)
					if can_stop_move or position.x >= 270:
						velocity = Vector2.ZERO
						can_stop_move = false
						current_state = State.FLASH
						state_timer = 0.0
			
			State.FLASH:
				if tween and tween.is_running():
					tween.kill()
				
				var tween = create_tween()
				tween.set_parallel(false)
				tween.set_ease(Tween.EASE_IN_OUT)	# 两端的插值最慢
				for i in range(4):
					tween.tween_property(line, "modulate:a", 0, 0.07)
					tween.tween_property(line, "modulate:a", 1, 0.07)
				current_state = State.END
				state_timer = 0.0
			
			State.END:
				if state_timer >= 1.0:
					if tween and tween.is_running():
						tween.kill()
					
					var tween = create_tween()
					tween.set_ease(Tween.EASE_OUT_IN)	# 两端的插值最快
					tween.set_parallel(true)
					tween.tween_property(target, "scale", Vector2(0, 0), 0.1)
				
				player_attack_audio.play(0.0)
				player_attack.play("slice")
				if sans_can_miss:
					sans.miss()
					sans_can_miss = false
				miss_ani.play_miss_ani()

				
				if state_timer >= 1.7:
					menu_node.exit_menu_mode()
					target.visible = false
					current_state = State.IDLE
					menu_node.state_timer = 0.0
