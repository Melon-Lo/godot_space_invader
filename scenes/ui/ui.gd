extends MarginContainer

@onready var score_label: Label = %ScoreLabel
@onready var damage_bar: ProgressBar = %VBoxContainer/HBoxContainer/ShieldBar/Background/DamageBar
@onready var actual_bar: ProgressBar = %VBoxContainer/HBoxContainer/ShieldBar/Background/ActualBar
@onready var energy_bar: ProgressBar = %VBoxContainer/HBoxContainer2/EnergyBar/Background/ActualBar
@onready var energy_icons = [
	%VBoxContainer/HBoxContainer2/IconHBox/EnergyIcon1/Sprite,
	%VBoxContainer/HBoxContainer2/IconHBox/EnergyIcon2/Sprite,
	%VBoxContainer/HBoxContainer2/IconHBox/EnergyIcon3/Sprite,
]

var damage_tween: Tween


# 更新分數
func update_score(value: int) -> void:
	score_label.text = "%08d" % value


# 更新護盾
func update_shield(max_value, value) -> void:
	actual_bar.max_value = max_value
	damage_bar.max_value = max_value

	# 停止先前尚未跑完的 Tween
	if damage_tween and damage_tween.is_valid():
		damage_tween.kill()

	# 如果是初始化、回血、或者滿血狀態，直接更新不作動畫
	if value == max_value or value >= actual_bar.value:
		actual_bar.value = value
		damage_bar.value = value
		return

	# 扣血：前方的實際血量立刻變動
	actual_bar.value = value

	# 後方的預扣紅色血量以 Tween 延遲後滑動退回
	damage_tween = create_tween()
	damage_tween.tween_interval(0.3) # 停頓 0.3 秒供玩家反應
	var tween_prop = damage_tween.tween_property(damage_bar, "value", value, 0.4)
	tween_prop.set_trans(Tween.TRANS_SINE)
	tween_prop.set_ease(Tween.EASE_OUT)


func _ready() -> void:
	# 一開始三個 Icon 都會隱藏
	for icon in energy_icons:
		if icon:
			icon.visible = false


# 更新能量
func update_energy(value: int) -> void:
	energy_bar.value = value

	# 根據能量值決定顯示的 icon 數量
	var show_count = 0
	if value >= 100:
		show_count = 3
	elif value >= 66:
		show_count = 2
	elif value >= 33:
		show_count = 1

	for i in range(energy_icons.size()):
		if energy_icons[i]:
			energy_icons[i].visible = i < show_count
