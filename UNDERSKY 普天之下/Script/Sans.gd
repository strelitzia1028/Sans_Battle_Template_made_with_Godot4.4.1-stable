# Sans.gd
extends CharacterBody2D

@export var sans_dialogue_box: DialogueBox
@export var initial_position: Vector2 = Vector2(0.0, -175.0)
@export var miss_distance: float = 100.0
@export var miss_velocity: float = 200.0
@export var can_miss: bool = false
@export var can_back: bool = false

func _process(delta: float) -> void:
	if can_miss:
		if position.x < miss_distance and not can_back:
			position.x += miss_velocity * delta
		elif position.x >= miss_distance and not can_back:
			position.x = miss_distance
			can_back = true
		elif position.x > initial_position.x and can_back:
			position.x -= miss_velocity * delta
		elif position.x <= initial_position.x and can_back:
			position.x = initial_position.x
			can_back = false
			can_miss = false

func miss():
	can_miss = true
