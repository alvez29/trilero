class_name CupSelectionComponent
extends Node

## Emitted when a cup selection area is hovered, with the slot index.
signal on_cup_hovered(slot_index: int)
## Emitted when a cup selection area is unhovered, with the slot index.
signal on_cup_unhovered(slot_index: int)
## Emitted when a cup selection area is clicked, with the slot index.
signal on_cup_clicked(slot_index: int)


## Ordered array of ClickArea nodes. Index matches the slot index.
@export var selection_areas: Array[ClickArea] = []

var _should_select := false
var last_known_mouse_area := -1

#region Lifecycle methods
func _ready() -> void:
	for i in selection_areas.size():
		var area := selection_areas[i]
		
		area.mouse_entered.connect(_on_area_hovered.bind(i))
		area.mouse_exited.connect(_on_area_unhovered.bind(i))
		area.on_clicked.connect(_on_area_clicked.bind(i))
	
	UIState.game_ui_state.is_playing_round.reactive_changed.connect(_on_game_ui_state_is_playing_round_reactive_changed)
#endregion

#region Public methods
## Disable the area selection. Component will still receiving mouse events but
## won't emit any signal
func disable_selection():
	_should_select = false

## Enable the area selection.
func enable_selection():
	_should_select = true
#endregion

#region Signals events
func _on_game_ui_state_is_playing_round_reactive_changed(is_playing_round: ReactiveBool):
	if is_playing_round.value:
		disable_selection()
	else:
		enable_selection()
	
	_on_area_hovered(last_known_mouse_area)


func _on_area_hovered(slot_index: int) -> void:
	last_known_mouse_area = slot_index
	
	if _should_select:
		on_cup_hovered.emit(slot_index)


func _on_area_unhovered(slot_index: int) -> void:
	last_known_mouse_area = -1
	on_cup_unhovered.emit(slot_index)


func _on_area_clicked(slot_index: int) -> void:
	if _should_select:
		on_cup_clicked.emit(slot_index)
#endregion
