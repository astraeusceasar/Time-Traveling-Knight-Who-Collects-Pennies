class_name Player
extends CharacterBody2D


const SPEED: float = 300.0
const SPRINT_SPEED: float = 600.0
const JUMP_VELOCITY: float = -700.0
const ACCEL: float = 1500
const GRAVITY_SCALAR: float = 1

var input: Vector2 = Vector2(0,0)

var last_dir: float = 1
var sprint: bool = false


enum PlayerStates {
	IDLE,
	MOVE,
	REWIND,
}


var state: PlayerStates = PlayerStates.IDLE
var positions := [Vector2]

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	

func _physics_process(delta: float) -> void:
	
	process_input()
	process_movement(delta)
		
	play_animation()
	move_and_slide()
	
	if (state == PlayerStates.MOVE):
		positions.append()
	
		

func process_input():
	input = Input.get_vector("left", "right","up","down")
	if (input.length() > 1.0):
		input = input.normalized()
	
	if (input):
		state = PlayerStates.MOVE
	else:
		state = PlayerStates.IDLE

func process_movement(delta: float) -> void:
	sprint = Input.is_action_pressed("sprint")
	if !is_on_floor():
		velocity.y += get_gravity().y * delta * GRAVITY_SCALAR
	
	if (state == PlayerStates.MOVE):
			
		if Input.is_action_just_pressed("up") && is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if (sprint):
			velocity.x = move_toward(velocity.x, input.x * SPRINT_SPEED, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, input.x * SPEED, ACCEL * delta)
		
	else:
		velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		
	if (Input.get_axis("left", "right")):
		last_dir = Input.get_axis("left", "right")


func play_animation() -> void:
	animated_sprite_2d.flip_h = last_dir < 0
	if (state == PlayerStates.MOVE):
		if (sprint):
			#animated_sprite_2d.play("run_right")
		else:
			#animated_sprite_2d.play("walk_right")
	else:
		animated_sprite_2d.play("idle_right")
	
			
