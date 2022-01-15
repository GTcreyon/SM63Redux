Files in this directory:
translations [folder] - Contains all .po files. These are the individual translation files, each corresponding to a different locale/language. 
redux.pot - Contains the template for all translations in the game, written in English. This should be loaded in poedit and used to create offshoot .po files.
generate_template.bat - Generates the redux.pot file from the game source by extracting translatable strings. Run this every time the game is updated to make sure the template is up-to-date.
babelrc - Needed for generate_template.bat to function properly.
