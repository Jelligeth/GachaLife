extends Control
class_name StoryUI

const TITLE_DURATION = 2
const STORY_DURATION = 1
const DIALOGUE_DURATION = 0.5

@export_category("Characters")
@export var characters: Dictionary = {}
@export_category("Image Elements")
@export var image_panel: MarginContainer
@export var background: TextureRect
@export var image: TextureRect
@export var fade: ColorRect
@export_category("Story Elements")
@export var story_panel: Panel
@export var story_text: RichTextLabel
@export_category("Dialogue Elements")
@export var dialogue_panel: Control
@export var dialogue_image: TextureRect
@export var dialogue_name: RichTextLabel
@export var dialogue_text: RichTextLabel
@export_category("Assist Label")
@export var hint: MarginContainer
@export var fade_color: Color
@export var transparent: Color

var assets: StoryAssets = null

func _ready() -> void:
	story_panel.hide()
	dialogue_panel.hide()
	set_image_visiblity(true)
	hide()


func setup_story(chapter_assets: StoryAssets) -> void:
	assets = chapter_assets
	show()


func show_title(data: Dictionary) -> void:
	show_image(data["image"])
	dialogue_panel.hide()
	story_text.remove_theme_color_override("default_color")
	story_text.text = "[b]" + data["text"] + "[/b]"
	story_text.visible_ratio = 0
	var tween: Tween = create_tween()
	tween.tween_property(story_text, "visible_ratio", 1, TITLE_DURATION)
	story_panel.show()

func set_image_visiblity(enable: bool) -> void:
	if enable and not image_panel.visible:
		fade.color = fade_color
		background.show()
		image.show()
		image_panel.show()
	elif not enable and image_panel.visible:
		background.hide()
		image.hide()
		var tween = create_tween()
		tween.tween_property(fade, "color", transparent, STORY_DURATION)
		await tween.finished
		image_panel.hide()

func show_image(image_name: String) -> void:
	if image_name == "none":
		await set_image_visiblity(false)
	elif image_name == "black":
		await set_image_visiblity(true)
		if fade.color != Color.BLACK:
			var tween = create_tween()
			tween.tween_property(fade, "color", Color.BLACK, STORY_DURATION)
		image_panel.hide()
	elif assets != null and assets.images.has(image_name):
		await set_image_visiblity(true)
		image.texture = assets.images[image_name]
		var tween = create_tween()
		tween.tween_property(fade, "color", transparent, STORY_DURATION)


func write_story(data: Dictionary) -> void:
	dialogue_panel.hide()
	story_text.remove_theme_color_override("default_color")
	show_image(data["image"])
	var character: Character = characters[data["name"]]
	var text: String = data["text"]
	story_text.add_theme_color_override("default_color", character.color)
	story_text.text = text
	story_text.visible_ratio = 0
	var tween: Tween = create_tween()
	tween.tween_property(story_text, "visible_ratio", 1, STORY_DURATION)
	story_panel.show()
	show_continue()


func write_dialogue(data: Dictionary) -> void:
	await set_image_visiblity(false)
	story_panel.hide()
	var character: Character = characters[data["name"]]
	dialogue_image.texture = character.expressions[data["image"]]
	dialogue_name.text = "[b]" + character.name + ":[/b] "
	dialogue_name.add_theme_color_override("default_color", character.color)
	dialogue_text.text = data["text"]
	dialogue_text.visible_ratio = 0
	var tween: Tween = create_tween()
	tween.tween_property(dialogue_text, "visible_ratio", 1, DIALOGUE_DURATION)
	dialogue_panel.show()
	show_continue()

func hide_story() -> void:
	await set_image_visiblity(false)
	story_panel.hide()

func hide_dialogue() -> void:
	dialogue_panel.hide()

func show_continue() -> void:
	hint.show()

func hide_continue() -> void:
	hint.hide()
