extends Label

@onready var health_label: Label = $"."

func _on_player_update_health(health: int) -> void:
	if (health && health_label):
		health_label.text = "Health: " + str(health) + "/5"
		


func _on_player_die() -> void:
	health_label.text = "Health: 5/5"
