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
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_hitbox: Area2D = $EnemyHitbox

var direction: float = 1

var health: int = 1

func _physics_process(delta: float) -> void:
	movement(delta)
	
	play_animation()
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
			
func play_animation() -> void:
	animated_sprite_2d.flip_h = direction < 0
				
	animated_sprite_2d.play("walk")



func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	print(area.name)
	if (area.name == "SwordRight" || area.name == "SwordLeft"):
		health -= 1
		if (health <= 0):
			animated_sprite_2d.play("die")
		
		



func _on_animated_sprite_2d_animation_finished() -> void:
	if health <= 0:
		queue_free()
