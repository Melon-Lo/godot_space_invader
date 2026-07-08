extends Label

# 初始化警告訊息並播放漂浮淡出動畫
func start(message: String) -> void:
	self.text = message
	self.position.y = 265
	self.modulate.a = 1.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", 240, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
