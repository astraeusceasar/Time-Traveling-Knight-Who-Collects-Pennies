extends Label

@onready var cash_label: Label = $"."
var cash: int = 0

func _ready() -> void:
	cash = 0
	text = "Cash: $0 (You're broke)"


func _on_player_die() -> void:
	cash = 0
	text = "Cash: $0 (You're broke)"


func _on_player_coin_up() -> void:
	cash += 1000
	text = "Cash: $" + str(cash)
	
