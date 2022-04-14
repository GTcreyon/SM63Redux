extends OptionButton

func _ready():
	var i = 0
	for locale in Singleton.LOCALES:
		add_item(" %s [%s]" % [locale[1], locale[0]], i)
		if locale[0] == TranslationServer.get_locale().substr(0, 2):
			selected = i
		i += 1


func _on_Locale_item_selected(index):
	TranslationServer.set_locale(Singleton.LOCALES[index][0])
