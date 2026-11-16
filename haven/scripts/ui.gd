extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var v_box_container: VBoxContainer = $Panel/VBoxContainer

func update(health: int, coins: int):
	var healthLabel:= Label.new()
	var coinLabel := Label.new()
	healthLabel.text = "Health: " + str(health) + "/3"
	coinLabel.text = "Coins: " + str(coins)
	
	
	
