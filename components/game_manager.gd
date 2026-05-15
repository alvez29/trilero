## Manage the game flow. Swapping
class_name TrileroGameManager
extends GameManager

@export_category("Components")
@export var cup_manager: CupManager

@export_category("Settings")
## Number of swaps per round
@export var swaps_per_round: int = 5

var _is_swapping: bool = false

#region Lifecycle methods
func _ready() -> void:
	start_round()
#endregion

#region Public methods
## Starts a round of random cup swaps.
func start_round() -> void:
	if _is_swapping:
		return
	
	_is_swapping = true
	UIState.game_ui_state.is_playing_round.value = true

	for i in swaps_per_round:
		await swap_random_pair()

	_is_swapping = false
	UIState.game_ui_state.is_playing_round.value = false


## Picks two distinct random cups and swaps them.
func swap_random_pair() -> void:
	var shuffled := cup_manager.cups.duplicate()
	shuffled.shuffle()
	
	await cup_manager.swap_cups(shuffled[0].id, shuffled[1].id)
#endregion
