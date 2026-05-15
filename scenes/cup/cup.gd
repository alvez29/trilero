class_name Cup
extends Node3D

const LIGHT_MASK_CIRCLE_ATTENUATION = 0.4

@onready var cup_mesh: MeshInstance3D = %CupMesh
@onready var light_mask_cone: MeshInstance3D = %LightMaskCone
@onready var light_mask_circle: MeshInstance3D = %LightMaskCircle
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var light_on_energy := 5.0
@export var turn_on_light_duration := 0.2
@export var turn_off_light_duration := 0.4
@export var shaker_component: ShakerComponent

@export var id: int = -1

var _light_cone_material: StandardMaterial3D
var _light_circle_material: StandardMaterial3D
var _selection_tween: Tween

var is_spot_light_on: bool:
	get:
		return _light_cone_material.albedo_color.a > 0 if _light_cone_material else false

func _ready() -> void:
	if cup_mesh:
		cup_mesh.rotation.y = randf_range(-PI, PI)
	
	if light_mask_cone:
		_light_cone_material = light_mask_cone.mesh.surface_get_material(0)
		
		if _light_cone_material is StandardMaterial3D:
			_light_cone_material.albedo_color.a = 0.0
	
	if light_mask_circle:
		light_mask_circle.rotation.y = randf_range(-PI, PI)
		_light_circle_material = light_mask_circle.mesh.surface_get_material(0)
		
		if _light_circle_material is StandardMaterial3D:
			_light_circle_material.albedo_color.a = 0.0

func turn_on_spot_light():
	if _selection_tween and _selection_tween.is_valid():
		_selection_tween.kill()
	
	_selection_tween = get_tree().create_tween()
	_selection_tween.set_parallel(true)
	
	
	if _light_cone_material:
		_selection_tween.tween_property(_light_cone_material, "albedo_color:a", 1.0, turn_on_light_duration)
	
	if _light_circle_material:
		_selection_tween.parallel().tween_property(_light_circle_material, "albedo_color:a", LIGHT_MASK_CIRCLE_ATTENUATION, turn_on_light_duration)

func turn_off_spot_light():
	if _selection_tween and _selection_tween.is_valid():
		_selection_tween.kill()
	
	_selection_tween = get_tree().create_tween()
	_selection_tween.set_parallel(true)
		
	if _light_cone_material:
		_selection_tween.tween_property(_light_cone_material, "albedo_color:a", 0.0, turn_off_light_duration)
	
	if _light_circle_material:
		_selection_tween.parallel().tween_property(_light_circle_material, "albedo_color:a", 0.0, turn_on_light_duration)


func on_cup_hovered():
	turn_on_spot_light()
	if shaker_component: 
		shaker_component.start_continuous_shake()

func on_cup_unhovered():
	turn_off_spot_light()
	if shaker_component: 
		shaker_component.stop_shake()
