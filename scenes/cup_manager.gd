## Manage and save the cup positions data and apply custom operations to them.
class_name CupManager
extends Node

@export_category("Components")
@export var hud_selection_component: CupSelectionComponent

@export_category("Nodes")
## Ordered array of Area3D slots. The index is the slot_id.
@export var slots: Array[Area3D] = []
## Ordered array of Cups.
@export var cups: Array[Cup] = []

@export_category("Settings")
@export var swap_duration: float = 0.4
@export var swap_arc_height: float = 0.15

## Mapping cup_id → slot_index
var _cup_to_slot: Dictionary = {}
## Inverse mapping slot_index → cup_id
var _slot_to_cup: Dictionary = {}

#region Lifecycle methods
func _ready() -> void:
	_assign_cups_to_nearest_slots()

	if hud_selection_component:
		hud_selection_component.on_cup_hovered.connect(_on_slot_hovered)
		hud_selection_component.on_cup_unhovered.connect(_on_slot_unhovered)
#endregion

#region Public methods
## Get the position of the slot by its index.
##
## [param slot_index] The index of the slot
##
## [return] The slot position as a Vector3
func get_slot_position(slot_index: int) -> Vector3:
	return slots[slot_index].global_position


## Get the slot index where a cup is currently located.
##
## [param cup_id] The id of the cup
##
## [return] The slot index
func get_cup_slot(cup_id: int) -> int:
	return _cup_to_slot[cup_id]


## Get the cup by its id of the given slot index.
##
## [param slot_index] The index slot
##
## [return] The cup id
func get_cup_id_at_slot(slot_index: int) -> int:
	return _slot_to_cup.get(slot_index, -1)


## Get the cup object by its id.
##
## [param cup_id] The cup id
##
## [return] The cup object. If the cup is not found return -1
func get_cup(cup_id: int) -> Cup:
	for cup in cups:
		if cup.id == cup_id:
			return cup
	return null

## Visually swap 2 cups and update its corresponding data
##
## [param cup_a_id] A cup id
## [param cup_b_id] Another cup id
func swap_cups(cup_a_id: int, cup_b_id: int) -> void:
	var cup_a := get_cup(cup_a_id)
	var cup_b := get_cup(cup_b_id)

	var cup_pos := cup_a.global_position
	var other_cup_pos := cup_b.global_position

	var tween := get_tree().create_tween()
	tween.set_parallel(true)

	# Perpendicular direction in XZ plane for the arc offset
	var direction := (other_cup_pos - cup_pos)
	direction.y = 0.0
	var perpendicular := direction.cross(Vector3.UP).normalized()

	# Cup A arcs to one side, Cup B arcs to the other
	_tween_arc(tween, cup_a, cup_pos, other_cup_pos, perpendicular * swap_arc_height, swap_duration)
	_tween_arc(tween, cup_b, other_cup_pos, cup_pos, perpendicular * -swap_arc_height, swap_duration)

	await tween.finished

	update_cup_maps(cup_a_id, cup_b_id)


## Swaps two cups' slot assignments (data only, no animation). Adjust 
## their corresponding maps. 
## [b] IMPORTANT: This needs to be called every time a cup is translated in its visual
## representation. [\b]
##
## [param cup_a_id] The cup id of a cup
## [param cup_b_id] The cup id of another cup
func update_cup_maps(cup_a_id: int, cup_b_id: int) -> void:
	var slot_a: int = _cup_to_slot[cup_a_id]
	var slot_b: int = _cup_to_slot[cup_b_id]
	_assign_cup_to_slot(cup_a_id, slot_b)
	_assign_cup_to_slot(cup_b_id, slot_a)
	
#endregion

#region Private methods
## Assign each loaded cups to their nearest slot. This is only used at [b]_ready[\b]
## function since it's used only for initialize the dictionaries.
func _assign_cups_to_nearest_slots() -> void:
	var taken_slots: Array[int] = []

	for cup in cups:
		var cup_pos := cup.global_position
		var best_slot := -1
		var best_dist := INF

		for slot_index in slots.size():
			if slot_index in taken_slots:
				continue
			var dist := cup_pos.distance_squared_to(slots[slot_index].global_position)
			if dist < best_dist:
				best_dist = dist
				best_slot = slot_index

		_assign_cup_to_slot(cup.id, best_slot)
		taken_slots.append(best_slot)

## Assign a cup to a slot. 
##
## [param cup_id] The cup id
## [param slot_index] The desired slot index
func _assign_cup_to_slot(cup_id: int, slot_index: int) -> void:
	_cup_to_slot[cup_id] = slot_index
	_slot_to_cup[slot_index] = cup_id


## Tweens a node along a parabolic arc from start to end position.
##
## [param tween] The tween reference
## [param node] The subject node
## [param from] The origin position
## [param to] The target position
## [param arc_offset] The lateral displacement vector at the peak of the arc
## [param duration] The duration of the displacement
func _tween_arc(tween: Tween, node: Node3D, from: Vector3, to: Vector3, arc_offset: Vector3, duration: float) -> void:
	tween.tween_method(
		func(t: float) -> void:
			var lerped := from.lerp(to, t)
			lerped += arc_offset * 4.0 * t * (1.0 - t)
			node.global_position = lerped,
		0.0, 1.0, duration
	)

#region Signal events 
func _on_slot_hovered(slot_index: int) -> void:
	var cup_id := get_cup_id_at_slot(slot_index)
	var cup := get_cup(cup_id)
	if cup:
		cup.on_cup_hovered()


func _on_slot_unhovered(slot_index: int) -> void:
	var cup_id := get_cup_id_at_slot(slot_index)
	var cup := get_cup(cup_id)
	if cup:
		cup.on_cup_unhovered()
#endregion
#endregion
