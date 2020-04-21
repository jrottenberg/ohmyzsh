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
function prompt_azure() {
  [[ ! -f "${AZURE_CONFIG_DIR:-$HOME/.azure/accessTokens.json}" ]] && return
  echo "${ZSH_THEME_AZURE_PREFIX:=<az:}$(azgs)${ZSH_THEME_AZURE_SUFFIX:=>}"
}

if [ "$SHOW_AZ_PROMPT" != false ]; then
  RPROMPT='$(prompt_azure)'"$RPROMPT"
fi


# Load az completions
function _az-homebrew-installed() {
  # check if Homebrew is installed
  (( $+commands[brew] )) || return 1

  # speculatively check default brew prefix
  if [ -h /usr/local/opt/az ]; then
    _brew_prefix=/usr/local/opt/az
  else
    # ok, it is not in the default prefix
    # this call to brew is expensive (about 400 ms), so at least let's make it only once
    _brew_prefix=$(brew --prefix azure-cli)
  fi
}

# get az.completion.sh location from $PATH
_az_zsh_completer_path="$commands[az_zsh_completer.sh]"

# otherwise check common locations
if [[ -z $_az_zsh_completer_path ]]; then
  # Homebrew
  if _az-homebrew-installed; then
    _az_zsh_completer_path=$_brew_prefix/libexec/bin/az.completion.sh
  # Ubuntu
  elif [[ -e /opt/az/bin/az.completion.sh ]]; then
    _az_zsh_completer_path=/opt/az/bin/az.completion.sh
  # RPM
  else
    _az_zsh_completer_path=/etc/bash_completion.d/azure-cli
  fi
fi

[[ -r $_az_zsh_completer_path ]] && source $_az_zsh_completer_path
unset _az_zsh_completer_path _brew_prefix
