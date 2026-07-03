extends Area2D

@export var speed: float = 150.0


func start(pos: Vector2) -> void:
	position = pos


func _process(delta: float) -> void:
	position.y += speed * delta


# 移出畫面
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


# 處理碰撞
func _on_area_entered(area: Area2D) -> void:
	if area.name == "Player":
		queue_free()
		area.shield -= 1
