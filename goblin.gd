extends CharacterBody2D

@export var speed = 50
@export var attack = 10
@export var attack_range = 50.0 
@export var hp = 100
var player = null
var is_attacking = false # 新增：用來記錄目前是否正在攻擊
var gem_scene = preload("res://gem.tscn")
func _ready():
	player = get_tree().root.find_child("Player", true, false)
	
func _physics_process(delta):
	if player:
		
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
func take_damage(amount):
	hp -= amount
	print("被玩家攻擊！目前：",hp)
	if hp<0:
		die()
func die():
	var gem = gem_scene.instantiate()
	# 建議先設定位置，再 add_child
	gem.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", gem)
	queue_free()  #todo 隨機掉落物

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
			player.take_damage(attack)
			print("砰！玩家扣血")
			
