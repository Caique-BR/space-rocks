extends Node

var utility_text_box : RichTextLabel
var text_array : Array[String]

func start(text_box: RichTextLabel) -> void:
	utility_text_box = text_box

func print_on_screen(text: Variant):
	utility_text_box.text = ""
	utility_text_box.add_text(str(text))
