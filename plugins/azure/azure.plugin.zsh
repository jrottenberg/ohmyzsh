function azgp() {
  echo $AWS_PROFILE
}

# AWS profile selection
function asp() {
  if [[ -z "$1" ]]; then
    unset AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE
    echo AWS profile cleared.
    return
  fi

  local -a available_profiles
  available_profiles=($(aws_profiles))
  if [[ -z "${available_profiles[(r)$1]}" ]]; then
    echo "${fg[red]}Profile '$1' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
    echo "Available profiles: ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
    return 1
  fi

  export AWS_DEFAULT_PROFILE=$1
  export AWS_PROFILE=$1
  export AWS_EB_PROFILE=$1
}


function aws_profiles() {
  [[ -r "${AZURE_CONFIG_DIR:-$HOME/.azure/azureProfile.json}" ]] || return 1
  grep '\[profile' "${AWS_CONFIG_FILE:-$HOME/.aws/config}"|sed -e 's/.*profile \([a-zA-Z0-9_\.-]*\).*/\1/'
}

function _aws_profiles() {
  reply=($(aws_profiles))
}
compctl -K _aws_profiles asp aws_change_access_key

# AWS prompt
function aws_prompt_info() {
  [[ -z $AWS_PROFILE ]] && return
  echo "${ZSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE}${ZSH_THEME_AWS_SUFFIX:=>}"
}

if [ "$SHOW_AWS_PROMPT" != false ]; then
  RPROMPT='$(aws_prompt_info)'"$RPROMPT"
fi


# Load azure-cli completions

function az-homebrew-installed() {
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

  # get az_zsh_completer.sh location from $PATH
  _az_zsh_completer_path="$commands[az_zsh_completer.sh]"

  # otherwise check common locations
  if [[ -z $_az_zsh_completer_path ]]; then
    # Homebrew
    if _az-homebrew-installed; then
      _az_zsh_completer_path=$_brew_prefix/libexec/bin/az.completion.sh
    # Ubuntu
    elif [[ -e /opt/az/bin/az.completion.sh ]]; then
      _aws_zsh_completer_path=/opt/az/bin/az.completion.sh
    # RPM
    else
      _aws_zsh_completer_path=/etc/bash_completion.d/azure-cli
    fi
  fi

  [[ -r $_az_zsh_completer_path ]] && source $_az_zsh_completer_path
  unset _az_zsh_completer_path _brew_prefix
fi
