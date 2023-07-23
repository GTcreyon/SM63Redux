# Guidelines
## Reporting bugs
### One issue for one bug
Generally, try to make sure that every bug has only one issue, and every issue has only one bug. To do this:
* Ensure you check for any duplicate issues before posting one.
* If you have found multiple bugs, post multiple issues - one for each.
### Steps to reproduce
Ensure that you provide as much detail as possible on *how* the bug happened. Things that may seem irrelevant may in fact be very relevant. We won't judge you for missing anything, or telling us things we don't need to know. Just do your best to give as much info as possible.
## Contributing code
### Preparation
If you would like to make a contribution, begin by posting a feature request in the "Issues" section. This will allow us to review your plans, suggest alterations, or potentially reject the idea if necessary. From there, you can fork the project, make your alterations, and issue a pull request.
### Branching
Name your branches using the following conventions (fill the blanks as appropriate):
- `feature-___` if the branch adds large-scale features, such as entire enemies, items, or systems.
Example: `feature-shy-guys`
- `enhance-___` when an existing feature is being tweaked or added to.
Example: `enhance-fludd-spray`
- `refactor-___` for changes that make the code nicer to work with.
(Since nodes interact so tightly with the code, they are counted as part of this category.)
Example: `refactor-enemy-base-class`
- `bugfix-___` when _only_ fixing something that doesn't work right. Branches in other categories can also fix bugs, of course.
Example: `bugfix-fish-not-hurting-player`
- `asset-___` when _only_ integrating art/sound assets into the project. Features and enhancements may also introduce assets.
Example: `asset-bobomb-sfx`
- `repo-___` if the change affects the GitHub repository, e.g. `README.md` or `CONTRIBUTING.md`.
Example: `repo-clarify-styleguide`

Delete branches once they've been merged, to keep the tree clean.
### Styling
Follow the [Godot style guide](https://docs.godotengine.org/en/4.1/tutorials/scripting/gdscript/gdscript_styleguide.html) as closely as possible, albeit with the following alterations:
* The keywords `and` and `or` are used in place of the C-like `&&` and `||` as-per the style guide, however we use the `!` symbol as opposed to `not`, to allow easier reading of more complex boolean expressions. So, `if !foo and !bar:`
* When unfolding longer lines we only use *one* tab, not two. This is contrary to the Godot style guide.
### Documentation
Comment responsibly.
* Write frequent, descriptive comments that will make it easy for any reader to understand.
* Please keep your code comments polite. It's okay to joke around, but, remember everyone can see what you write. Don't embarrass yourself, okay?
### Commits
Do your best to write clear, concise, readable commit messages.
Also, try to keep one commit for each change, and one pull request for each feature. Generally, avoid making multiple changes in one go.
