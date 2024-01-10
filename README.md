# ltextra.nvim

`ltextra.nvim` is a plugin used to make easy the configuration and interation with [ltex](https://valentjn.github.io/ltex/settings.html). For example, to configure `ltex.enabledRules` (see the [Docs](https://valentjn.github.io/ltex/settings.html#ltexenabledrules)) you can use:

```lua
config = function()
  require("ltextra").setup({
    enabledRules = {
      "en-GB": {"PASSIVE_VOICE", "OXFORD_SPELLING_NOUNS"},
    },
  })
end,
```

`ltextra.nvim` also adds some functions to use with keymaps.

- `require('ltextra.actions').add_word()`: Add the word under cursor to the dictionary.
- `require('ltextra.actions').disable_rule()`: Add the word under cursor to the dictionary.

#### [Lazy](https://github.com/folke/lazy.nvim)

```lua
return {
  	"charlesneimog/ltextra.nvim",
  	dir = "~/Documents/Git/ltextra.nvim",
	keys = {
		{
			"aw",
			function()
				require("ltextra.actions").add_word()
			end,
			mode = "n",
			desc = "Add word to dictionary",
		},
	},
	event = "BufRead *.tex",
	config = function()
		require("ltextra").setup({
			language = "pt-BR",
	})
	end,
}
```
