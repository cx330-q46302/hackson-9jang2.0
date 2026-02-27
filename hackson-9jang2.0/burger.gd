extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("heal"):
		body.heal(100) # 呼叫角色的補血指令，補 100 點
		queue_free()   # 漢堡功成身退，從畫面上消失
