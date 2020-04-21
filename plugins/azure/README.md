# azure

This plugin provides completion support for [azure cli](https://docs.microsoft.com/en-us/cli/azure/)
and a few utilities to manage azure subscriptions and display them in the prompt.

To use it, add `azure` to the plugins array in your zshrc file.

```zsh
plugins=(... azure)
```

## Plugin commands

* `az_subscriptions`: lists the available subscriptions in the  `AZURE_CONFIG_DIR` (default: `~/.azure/`).
  Used to provide completion for the `azss` function.

* `azss [<subscription>]`: sets the `$azure_subscription`.

* `azgs`: gets the current value of `$azure_subscription`.
