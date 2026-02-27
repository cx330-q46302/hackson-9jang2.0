extends CharacterBody2D

var speed = 50
var player = null
var attack_range = 50.0 
var is_attacking = false # 新增：用來記錄目前是否正在攻擊

func _ready():
	player = get_tree().root.find_child("Player", true, false)

func _physics_process(delta):
	if player:
		print(is_attacking)
		# 如果正在攻擊中，就不執行移動和重複播放動畫的邏輯
		if is_attacking:
			return

		var distance = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		
		if distance <= attack_range:
			# --- 進入攻擊狀態 ---
			velocity = Vector2.ZERO
			start_attack()
		else:
			# --- 追逐狀態 ---
			velocity = direction * speed
			$AnimatedSprite2D.play("walk")
			
			# 翻轉邏輯放在移動時最準確
			$AnimatedSprite2D.flip_h = direction.x < 0
		
		move_and_slide()

# 發動攻擊的函數
func start_attack():
	is_attacking = true
	# 攻擊時也要面對玩家
	var direction = (player.global_position - global_position).normalized()
	$AnimatedSprite2D.flip_h = direction.x < 0
	$AnimatedSprite2D.play("attack")

# 當動畫播放完畢（這就是你的事件結尾）
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "attack":
		apply_damage_to_player()
		is_attacking = false # 攻擊結束，解除鎖定，讓怪物可以繼續移動或下次攻擊

func apply_damage_to_player():
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range + 15: # 給一點寬容值
		if player.has_method("take_damage"):
			player.take_damage(10)
			print("砰！玩家扣血")
