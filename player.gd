extends CharacterBody3D

# stats
var curHp : int = 10
var maxHp : int = 10
var ammo : int = 20
var global_ammo : int = 60
var score: int = 0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sensitivity = 0.1

# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouseDelta : Vector2 = Vector2()

var isHidden : bool = false;

@onready var camera : Camera3D = $Camera3D
@onready var pistol_animation : AnimationPlayer = $Camera3D/fps_pistol_animated2/AnimationPlayer
@onready var head_bob : AnimationPlayer = $Camera3D/AnimationPlayer
@onready var shoot_sound : AudioStreamPlayer3D = $ShootSound
@onready var reload_sound : AudioStreamPlayer3D = $ReloadSound
@onready var reload_sound2 : AudioStreamPlayer3D = $ReloadSound2
@onready var hide_sound : AudioStreamPlayer3D = $HideSound
@onready var unhide_sound : AudioStreamPlayer3D = $UnhideSound
@onready var footstep_sound : AudioStreamPlayer3D = $FootstepSound
@onready var dry_fire: AudioStreamPlayer3D = $DryFire
@onready var melee_sound: AudioStreamPlayer3D = $MeleeSound
@onready var muzzle: Node3D = $Camera3D/Muzzle
@onready var bulletScene = preload("res://bullet.tscn")


var rng = RandomNumberGenerator.new()

var reloading : bool = false
var firing : bool = false
var hiding : bool = false
var meleeing : bool = false

var gun_jammed : bool = false
var gun_unjamming : bool = false

var need_to_reload : bool = false


func _ready():
	# Hide the mouse cursor when in the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		footstep_sound.stop()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !pistol_animation.is_playing() and !isHidden and !hiding and !gun_jammed:
			pistol_animation.play('ambient')
			pistol_animation.seek(5.9667, true)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		footstep_sound.stop()
		head_bob.stop()
	

	#else:
	#	footstep_sound.stop()
	#	head_bob.stop()

	move_and_slide()
	
func _process(delta: float) -> void:
	
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	# rotate the player along their y axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	# reset the mouse delta vector
	mouseDelta = Vector2()
	
	if Input.is_action_just_pressed("forward") or Input.is_action_just_pressed("backward") or Input.is_action_just_pressed("strafe_left") or Input.is_action_just_pressed("strafe_right") and is_on_floor():
		footstep_sound.play()
		head_bob.play("head_bob", -1, 1.80)
	
	
	if Input.is_action_just_pressed("reload"):
		if isHidden:
			hide_animation()
		elif !hiding and !firing and !reloading and !meleeing:
			rng.randomize()
			var randNum = rng.randi_range(0,1)
			if gun_jammed:
				gun_unjamming = true
				pistol_animation.play("weild")
				pistol_animation.seek(4.7333, true)
				unhide_sound.play()
				isHidden = false
				await pistol_animation.animation_finished
				gun_jammed = false
				gun_unjamming = false
			elif global_ammo > 1:
				need_to_reload = false
				reloading = true
				if global_ammo > 20:
					global_ammo -= (20 - ammo)
					ammo += (20 - ammo)
				else:
					global_ammo -= (global_ammo - ammo)
					ammo += (global_ammo - ammo)
				if randNum == 0:
					pistol_animation.play("reload")
					pistol_animation.seek(0.3, true)
					reload_sound.play()	
				else:
					pistol_animation.play("reload2")
					pistol_animation.seek(2.1667, true)
					reload_sound2.play()
				await pistol_animation.animation_finished
				reloading = false
		isHidden = false
	
	if Input.is_action_just_pressed("shoot"):
		if isHidden:
			hide_animation()
		elif !hiding and !firing and !reloading and !meleeing:
			rng.randomize()
			var randNum = rng.randi_range(0,1000)
			firing = true
			if ammo < 1:
				pistol_animation.play("gun_jam")
				dry_fire.play()
				need_to_reload = true
			elif gun_jammed:
				pistol_animation.play("gun_jam")
				dry_fire.play()
			elif randNum == 0:
				pistol_animation.play("gun_jam")
				dry_fire.play()
				gun_jammed = true
			else: 
				pistol_animation.play("shoot")
				pistol_animation.seek(7.5, true)
				shoot()
				shoot_sound.play()
			isHidden = false
			await pistol_animation.animation_finished
			firing = false
	
	if Input.is_action_just_pressed("melee"):
		if !hiding and !firing and !reloading and !meleeing:
			meleeing = true
			pistol_animation.play("melee")
			pistol_animation.seek(6.8333, true)
			melee_sound.play()
			await pistol_animation.animation_finished
			meleeing = false
				

			
	if Input.is_action_just_pressed("hide_weapon"):
		if !hiding and !firing and !reloading and !meleeing:
			hiding = true
			hide_animation()
			await pistol_animation.animation_finished
			hiding = false


func hide_animation() -> void:
	if !isHidden:
		pistol_animation.play("hide")
		pistol_animation.seek(4.3667, true)
		hide_sound.play()
		isHidden = true
	else:				
		pistol_animation.play("weild")
		pistol_animation.seek(4.7333, true)
		unhide_sound.play()
		isHidden = false
	
func _input(event):
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func shoot():
	var bullet = bulletScene.instantiate()
	get_node("/root/MainScene").add_child(bullet)
	
	bullet.global_transform = muzzle.global_transform
	
	ammo -= 1
	
# called when an enemy damages us
func take_damage (damage):
	
	curHp -= damage
	
	#ui.update_health_bar(curHp, maxHp)
	
	if curHp <= 0:
		die()

# called when our health reaches 0	
func die ():
	
	get_tree().reload_current_scene()
	
func add_score (amount):
	
	score += amount
	#ui.update_score_text(score)
	
func add_health (amount):
	
	curHp += amount
	
	if curHp > maxHp:
		curHp = maxHp
		
	#ui.update_health_bar(curHp, maxHp)
	
func add_ammo (amount):
	
	global_ammo += amount
	#ui.update_ammo_text(ammo)
