extends Node2D

@export var speed: float = -180.0     # 向上移動速度
@export var amplitude: float = 20.0   # 螺旋的水平振幅
@export var frequency: float = 8.0    # 旋轉頻率

var time: float = 0.0


func _ready() -> void:
	add_to_group("bullets")
	$Strand1.area_entered.connect(_on_strand_area_entered)
	$Strand2.area_entered.connect(_on_strand_area_entered)


func _physics_process(delta: float) -> void:
	time += delta
	position.y += speed * delta

	# DNA 雙股螺旋計算
	var sin_val = sin(time * frequency)
	var cos_val = cos(time * frequency)

	var offset = sin_val * amplitude
	$Strand1.position.x = offset
	$Strand2.position.x = -offset

	# 藉由餘弦值動態縮放，模擬 3D 穿梭前後的立體視覺效果
	var scale_factor_1 = 0.6 + 0.4 * cos_val
	var scale_factor_2 = 0.6 - 0.4 * cos_val

	$Strand1.scale = Vector2(scale_factor_1, scale_factor_1)
	$Strand2.scale = Vector2(scale_factor_2, scale_factor_2)

	# 旋轉自轉效果
	$Strand1/Sprite2D.rotation += 5.0 * delta
	$Strand2/Sprite2D.rotation -= 5.0 * delta

	# 飛出螢幕後銷毀
	if position.y < -50:
		queue_free()


func _on_strand_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.explode()
