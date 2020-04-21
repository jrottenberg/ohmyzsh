# AZ Get Subscritions
function azgs() {
  az account show --output tsv | cut -f 6
}

# AZ Subscription Selection
function azss() {
  if [[ -z "$1" ]]; then
    # If no subscription ispassed we error out
    return 1
  fi

  local -a available_subscriptions
  available_subscriptions=($(az_subscriptions))
  if [[ -z "${available_subscriptions[(r)$1]}" ]]; then
    echo "${fg[red]}Subscription '$1' not found in  '${AZURE_CONFIG_DIR:-$HOME/.azure/azureProfile.json}'" >&2
    echo "Available subscriptions: ${(j:, :)available_subscriptions:-no subscriptions found}${reset_color}" >&2
    return 1
  fi

  az account set --subscription "${1}"
}

function az_subscriptions() {
  [[ -f "${AZURE_CONFIG_DIR:-$HOME/.azure}/accessTokens.json" ]] || return 1
  az account list  --all --output tsv --query '[*].name'
}

function _az_subscriptions() {
  reply=($(az_subscriptions))
}
compctl -K _az_subscriptions azss

# Az prompt
function az_prompt_info() {
  [[ ! -f "${AZURE_CONFIG_DIR:-$HOME/.azure/accessTokens.json}" ]] && return
  echo "${ZSH_THEME_AZ_PREFIX:=<az:}$(azgs)${ZSH_THEME_AZ_SUFFIX:=>}"
}

if [ "$SHOW_AZ_PROMPT" != false ]; then
  RPROMPT='$(az_prompt_info)'"$RPROMPT"
fi


# Load awscli completions

# AWS CLI v2 comes with its own autocompletion. Check if that is there, otherwise fall back
if [[ -x /usr/local/bin/aws_completer ]]; then
  autoload -Uz bashcompinit && bashcompinit
  complete -C aws_completer aws
else
  function _awscli-homebrew-installed() {
    # check if Homebrew is installed
    (( $+commands[brew] )) || return 1

    # speculatively check default brew prefix
    if [ -h /usr/local/opt/awscli ]; then
      _brew_prefix=/usr/local/opt/awscli
    else
      # ok, it is not in the default prefix
      # this call to brew is expensive (about 400 ms), so at least let's make it only once
      _brew_prefix=$(brew --prefix awscli)
    fi
  }

  # get aws_zsh_completer.sh location from $PATH
  _aws_zsh_completer_path="$commands[aws_zsh_completer.sh]"

  # otherwise check common locations
  if [[ -z $_aws_zsh_completer_path ]]; then
    # Homebrew
    if _awscli-homebrew-installed; then
      _aws_zsh_completer_path=$_brew_prefix/libexec/bin/aws_zsh_completer.sh
    # Ubuntu
    elif [[ -e /usr/share/zsh/vendor-completions/_awscli ]]; then
      _aws_zsh_completer_path=/usr/share/zsh/vendor-completions/_awscli
    # NixOS
    elif [[ -e "${commands[aws]:P:h:h}/share/zsh/site-functions/aws_zsh_completer.sh" ]]; then
      _aws_zsh_completer_path="${commands[aws]:P:h:h}/share/zsh/site-functions/aws_zsh_completer.sh"
    # RPM
    else
      _aws_zsh_completer_path=/usr/share/zsh/site-functions/aws_zsh_completer.sh
    fi
  fi

  [[ -r $_aws_zsh_completer_path ]] && source $_aws_zsh_completer_path
  unset _aws_zsh_completer_path _brew_prefix
fi
