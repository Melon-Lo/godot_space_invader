extends Control

@onready var ultimate_button: TouchScreenButton = $UltimateButton


func _ready() -> void:
	# 初始能量為 0，隱藏大招按鈕
	update_energy(0)


# 根據能量值更新大招按鈕的顯示狀態
func update_energy(value: int) -> void:
	if ultimate_button:
		ultimate_button.visible = value >= 33
