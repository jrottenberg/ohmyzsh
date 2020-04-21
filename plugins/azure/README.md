# azure

This plugin provides completion support for [azure cli](https://docs.microsoft.com/en-us/cli/azure/)
and a few utilities to manage azure subscriptions and display them in the prompt.

To use it, add `azure` to the plugins array in your zshrc file.

```zsh
plugins=(... azure)
```

## Plugin commands

* `azss [<subscription>]`: sets the `$azure_subscription`.

* `azgs`: gets the current value of `$azure_subscription`.

* `az_subscriptions`: lists the available subscriptions in the  `AZURE_CONFIG_DIR` (default: `~/.azure/`).
  Used to provide completion for the `azss` function.

## Plugin options

* Set `SHOW_azure_PROMPT=false` in your zshrc file if you want to prevent the plugin from modifying your RPROMPT.
  Some themes might overwrite the value of RPROMPT instead of appending to it, so they'll need to be fixed to
  see the azure subscription prompt.

## Theme

The plugin creates an `azure_prompt_info` function that you can use in your theme, which displays
the current `$azure_subscription`. It uses two variables to control how that is shown:

- ZSH_THEME_azure_PREFIX: sets the prefix of the azure_subscription. Defaults to `<azure:`.

- ZSH_THEME_azure_SUFFIX: sets the suffix of the azure_subscription. Defaults to `>`.
