extends LineEdit


## Initializes and focuses the widget.
func begin_new() -> void:
	grab_focus()
	clear()
	update_text()


## Triggers text-changed signal.
func update_text() -> void:
	emit_signal("text_changed", text)
