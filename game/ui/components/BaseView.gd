extends Control
class_name BaseView

func get_required_node(path: NodePath) -> Node:
	var node := get_node_or_null(path)
	if node == null:
		push_error("BaseView: Missing node at %s" % path)
	return node

func bind_button(path: NodePath, callable: Callable) -> Button:
	var button: Button = get_required_node(path)
	if button and not button.pressed.is_connected(callable):
		button.pressed.connect(callable)
	return button

func bind_slider(path: NodePath, callable: Callable, configure: Callable = Callable()) -> Slider:
	var slider: Slider = get_required_node(path)
	if slider:
		if configure and configure.is_valid():
			configure.call(slider)
		if not slider.value_changed.is_connected(callable):
			slider.value_changed.connect(callable)
	return slider

func bind_option_button(path: NodePath, callable: Callable, options: Array = []) -> OptionButton:
	var option_button: OptionButton = get_required_node(path)
	if option_button:
		if options.size() > 0:
			option_button.clear()
			for option in options:
				option_button.add_item(str(option))
		if not option_button.item_selected.is_connected(callable):
			option_button.item_selected.connect(callable)
	return option_button

func bind_toggle(path: NodePath, callable: Callable) -> BaseButton:
	var button: BaseButton = get_required_node(path)
	if button and not button.toggled.is_connected(callable):
		button.toggled.connect(callable)
	return button

func emit_view_signal(signal_name: StringName, args: Array = []) -> void:
	if not has_signal(signal_name):
		return
	callv("emit_signal", [signal_name] + args)
