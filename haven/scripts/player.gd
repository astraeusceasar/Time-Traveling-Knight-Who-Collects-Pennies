class_name Player
extends CharacterBody2D


const SPEED: float = 300.0
const SPRINT_SPEED: float = 600.0
const JUMP_VELOCITY: float = -700.0
const ACCEL: float = 1500
const GRAVITY_SCALAR: float = 1
const MAX_REWIND_POSITIONS: int = 100
const REWIND_FRAME_DELAY: float = 0.00001
const REWIND_RECORD_DELAY: float = 0.01

var input: Vector2 = Vector2(0,0)

var last_dir: float = 1
var sprint: bool = false
var health: int = 3
var sword_hitbox_offset: Vector2

var attack_anim: int = 0

enum PlayerStates {
	IDLE,
	MOVE,
	REWIND,
	ATTACK,
	HURT,
	DEAD,
}


var state: PlayerStates = PlayerStates.IDLE
var positions: Array[Vector2]
var bounce: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ghost: AnimatedSprite2D = $Ghost

@onready var rewind_replay_timer_frame: Timer = $RewindReplayTimerFrame
@onready var rewind_capture_timer_frame: Timer = $RewindCaptureTimerFrame
@onready var sword_hitbox: Area2D = $SwordHitbox

signal die

func _ready() -> void:
	ghost.modulate.a = 0.2
	sword_hitbox_offset = sword_hitbox.position
	sword_hitbox.monitoring = false
	
	
func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("reset")):
		reset()
		return
	process_input()
	process_movement(delta)
		
	manage_attacks()
	play_animation()
	move_and_slide()
	
	
	if (state == PlayerStates.MOVE || state == PlayerStates.IDLE):
		if (rewind_capture_timer_frame.is_stopped()):
			rewind_capture_timer_frame.start(REWIND_RECORD_DELAY)
		
	
		

func process_input():
	input = Input.get_vector("left", "right","up","down")
	if (input.length() > 1.0):
		input = input.normalized()
	
	if (state == PlayerStates.MOVE || state == PlayerStates.IDLE):
		if (input):
			state = PlayerStates.MOVE
		else:
			state = PlayerStates.IDLE

func process_movement(delta: float) -> void:
	if (Input.is_action_just_pressed("rewind")):
		#print(positions)
		#print("rewind")
		rewind_capture_timer_frame.stop()
		rewind_replay_timer_frame.start(REWIND_FRAME_DELAY)
		
	sprint = Input.is_action_pressed("sprint")
	if !is_on_floor():
		velocity.y += get_gravity().y * delta * GRAVITY_SCALAR
	if (bounce):
		bounce = false
		velocity.y = -1000
	match state:
		PlayerStates.MOVE:
			if Input.is_action_just_pressed("up") && is_on_floor():
				velocity.y = JUMP_VELOCITY
			
			if (sprint):
				velocity.x = move_toward(velocity.x, input.x * SPRINT_SPEED, ACCEL * delta)
			else:
				velocity.x = move_toward(velocity.x, input.x * SPEED, ACCEL * delta)
		PlayerStates.REWIND:
			if (!positions):
				state = PlayerStates.IDLE
			else:
				position = positions.pop_back()
		_:
			velocity.x = move_toward(velocity.x, 0, ACCEL * delta)
		
	if (Input.get_axis("left", "right")):
		last_dir = Input.get_axis("left", "right")


func play_animation() -> void:
	if (positions):
		ghost.global_position = positions[0]
		ghost.play("idle")
	
	animated_sprite_2d.flip_h = last_dir < 0
	ghost.flip_h = last_dir < 0
	
	if Input.is_action_just_pressed("up") && is_on_floor() && state != PlayerStates.DEAD:
		animated_sprite_2d.play("jump")
		return
				
	match state:
		PlayerStates.MOVE:
			if (velocity.y == 0):
				if (sprint):
					animated_sprite_2d.play("run")
				else:
					animated_sprite_2d.play("walk")
		PlayerStates.IDLE:
			if (velocity.y == 0):
				animated_sprite_2d.play("idle")
		
	
func manage_attacks():
	if (Input.is_action_just_pressed("attack") && state != PlayerStates.ATTACK && state != PlayerStates.DEAD):
		update_sword_hitbox()
		if (state == PlayerStates.IDLE || state == PlayerStates.MOVE):
			state = PlayerStates.ATTACK
			sword_hitbox.monitoring = true
			if (attack_anim == 0):
				animated_sprite_2d.play("attack_0")
				attack_anim = 1
			else:
				animated_sprite_2d.play("attack_1")
				attack_anim = 0
	
func update_sword_hitbox():
	var x := sword_hitbox_offset.x
	var y := sword_hitbox_offset.y
	
	if (last_dir < 0):
		sword_hitbox.position = Vector2(-x, y)
	else:
		sword_hitbox.position = Vector2(x, y)

func take_damage(damage: int = 1):
	state = PlayerStates.HURT
	animated_sprite_2d.play("hurt")
	health -= damage

func reset():
	health = 3
	state = PlayerStates.IDLE
	get_tree().reload_current_scene()

func _on_rewind_replay_timer_frame_timeout() -> void:
	rewind_capture_timer_frame.stop()
	if (positions):
		position = positions.pop_back()
		rewind_replay_timer_frame.start(REWIND_FRAME_DELAY)
	else:
		state = PlayerStates.IDLE
		rewind_replay_timer_frame.stop()
		

func _on_rewind_capture_timer_frame_timeout() -> void:
	positions.push_back(position)
	if (positions.size() > MAX_REWIND_POSITIONS):
		positions.remove_at(0)
	if (state != PlayerStates.REWIND):
		rewind_capture_timer_frame.start(REWIND_RECORD_DELAY)
	
func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if (area.name == "EnemyHitbox"):
		if (state != PlayerStates.HURT && state != PlayerStates.DEAD):
			take_damage()
	if (area.name == "TrampolineHitbox"):
		bounce = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if (state == PlayerStates.ATTACK):
		sword_hitbox.monitoring = false
		state = PlayerStates.IDLE
	elif (state == PlayerStates.HURT):
		if (health <= 0):
			state = PlayerStates.DEAD
			animated_sprite_2d.play("die")
			die.emit()
		else:
			state = PlayerStates.IDLE
	elif (state == PlayerStates.DEAD):
		reset()
		

func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if (body.name == "Enemy"):
		body.take_damage()
	
