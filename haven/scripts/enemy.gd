class_name Enemy
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum EnemyTypes {
	GOOMBA,
}

@export var type: EnemyTypes = EnemyTypes.GOOMBA
@onready var left_ray_cast: RayCast2D = $LeftRayCast
@onready var right_ray_cast: RayCast2D = $RightRayCast

var direction: float = 1

var health: int = 1

func _physics_process(delta: float) -> void:
	movement(delta)
	

	move_and_slide()

func movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match type:
		EnemyTypes.GOOMBA:
			if (!left_ray_cast.is_colliding()):
				direction = 1
			elif (!right_ray_cast.is_colliding()):
				direction = -1
				
			velocity.x = direction * SPEED
			
