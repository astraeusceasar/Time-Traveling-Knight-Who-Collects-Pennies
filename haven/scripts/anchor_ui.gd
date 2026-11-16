extends Panel
@onready var anchor_ui: Panel = $"."
@onready var player: Player = $"../../Player"

func _ready() -> void:
	anchor_ui.hide()
	


func _on_player_anchor_created() -> void:
	anchor_ui.show()


func _on_player_anchor_used() -> void:
	anchor_ui.hide()
