extends Area2D

@export var speed: float = -250.0

# 初始化
func start(pos: Vector2) -> void:
	position = pos

# 移動
func _process(delta: float) -> void:
	position.y += speed * delta

# 與敵人碰撞
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.explode()
		queue_free()

# 移出畫面
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

