extends GameManager
class_name StoryGameManager

const PROMPT_TIME = 2

@export var story_ui_scene: PackedScene

var story_ui: StoryUI = null
var story_data: Array = []
var assets: StoryAssets = null

var current_chapter: int = 0
var line_index: int = 0

var prompt_timer: Timer = null

var wait: bool = false
var game_actions: Dictionary = {}


func _virtual_ready() -> void:
	prompt_timer = Timer.new()
	prompt_timer.one_shot = true
	add_child(prompt_timer)
	story_ui = story_ui_scene.instantiate()
	add_child(story_ui)


func _input(event: InputEvent) -> void:
	if not wait:
		if (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT)\
		or event.is_action_pressed("ui_accept"):
			advance_story()


#Called by main after it calls setup
func start_story(chapter: Chapter) -> void:
	assets = chapter.assets
	story_ui.setup_story(assets)
	line_index = 0
	current_chapter = chapter.number
	story_data = chapter.story.data
	read_story()





func trigger_prompt_timeout() -> void:
	prompt_timer.start(0.05)

func advance_story() -> void:
	prompt_timer.stop()
	line_index += 1
	read_story()

func read_story() -> void:
	if line_index >= story_data.size():
		wait = true
		prompt_timer.stop()
		story_ui.hide()
		print("end of story")
		UIGlobals.return_to_chapters.emit()
		return
	var action: String = story_data[line_index]["action"]
	match action:
		"dialogue":
			story_ui.write_dialogue(story_data[line_index])
		"story":
			story_ui.write_story(story_data[line_index])
		"title":
			story_ui.show_title(story_data[line_index])
		"tiles":
			parse_tiles()
			advance_story()
		"game":
			await game_action(story_data[line_index])
			advance_story()
		"prompt":
			await show_prompt()
			advance_story()
		"highlight":
			highlighter(story_data[line_index])
			advance_story()
		"hide":
			story_ui.hide_story()
			story_ui.hide_dialogue()
			story_ui.hide_continue()
			advance_story()


func parse_tiles() -> void:
	assets.set_tile_order()
	GMGlobals.game_rules.tile_list.set_tile_list(assets.tile_order)


func game_action(_data: Dictionary) -> void:
	wait = true
	story_ui.hide_story()
	story_ui.hide_continue()
	var start_state: GMGlobals.States = GMGlobals.States.get(_data["state"])
	var end_state: GMGlobals.States = GMGlobals.States.get(_data["until"])
	GMGlobals.automate_until_state = end_state
	await progress_game(start_state)
	trigger_prompt_timeout()
	wait = false
	story_ui.show_continue()


func show_prompt() -> void:
	wait = true
	story_ui.show()
	story_ui.hide_continue()
	story_ui.write_dialogue(story_data[line_index])
	var time: float = story_data[line_index]["time"].to_float()
	prompt_timer.start(time)
	await prompt_timer.timeout
	wait = false


func highlighter(data: Dictionary) -> void:
	var player: Player = players[GMGlobals.Winds.EAST]
	var type = data["type"]
	match type:
		"freeze":
			player.lock_hand(true)
		"clear":
			table.clear_effects()
			player.lock_hand(false)
		"new":
			player.highlight_tile(0)
		"last":
			player.highlight_tile(-1)
		"tiles":
			player.highlight_tile(data["value"].to_int())
		"table":
			table.highlight_tiles(data["value"].to_int())

func clear_effects() -> void:
	players[GMGlobals.Winds.EAST].clear_highlights()
