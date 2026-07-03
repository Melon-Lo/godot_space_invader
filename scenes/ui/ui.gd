extends MarginContainer

@onready var shield_bar: ProgressBar = $HBoxContainer/ShieldBar
@onready var score_label: Label = $HBoxContainer/ScoreLabel


# 更新分數
func update_score(value: int) -> void:
	score_label.text = "%08d" % value


# 更新護盾
func update_shield(max_value, value) -> void:
	shield_bar.max_value = max_value
	shield_bar.value = value
