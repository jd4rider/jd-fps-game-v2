extends CharacterBody3D
	
# stats
var health : int = 5
var moveSpeed : float = 2.0

# attacking
var damage : int = 1
var attackRate : float = 1.0
var attackDist : float = 0.6

var scoreToGive : int = 10

# components
@onready var player : Node = get_node("/root/MainScene/Player")
@onready var timer: Timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	
	# setup the timer
	timer.set_wait_time(attackRate)
	timer.start()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# calculate the direction to the player
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	dir.y = 0
	
	#print(abs(dir.x) + abs(dir.z))
	# move the enemy towards the player
	if abs(dir.x) + abs(dir.z) > attackDist:
		if dir:
			velocity.x = dir.x * moveSpeed
			velocity.z = dir.z * moveSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, moveSpeed)
			velocity.z = move_toward(velocity.z, 0, moveSpeed)
		move_and_slide()

# called when we get damaged by the player
func take_damage (damage):
	
	health -= damage
	
	if health <= 0:
		die()

# called when our health reaches 0
func die ():
	
	player.add_score(scoreToGive)
	queue_free()

# deals damage to the player
func attack ():
	#pass
	print('aaaaaaaahhhhhhhhh')
	player.take_damage(damage)



func _on_timer_timeout() -> void:
	var dir = (player.global_transform.origin - global_transform.origin).normalized()
	dir.y = 0
	if abs(dir.x) + abs(dir.z) <= attackDist:
		attack()
