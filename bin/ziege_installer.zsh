#!/usr/bin/env zsh

# With thanks to the pyenv installer project

#set -e

# export ZIEGE_DEBUG="ON"

[ -n "$ZIEGE_DEBUG" ] && set -x

if [ -z "$ZIEGE_INSTALL_DIRECTORY" ]; then
  export ZIEGE_INSTALL_DIRECTORY="${HOME}/.ziege"
fi

colorize() {
  if [ -t 1 ]; then printf "\e[%sm%s\e[m" "$1" "$2"
  else echo -n "$2"
  fi
}

# Checks for `${HOME}/.ziege` directory, and suggests to remove it for installing
if [ -d "${ZIEGE_INSTALL_DIRECTORY}" ]; then
  { echo
    colorize 1 "WARNING"
    echo "Cannot proceed with installation. Kindly remove the '${ZIEGE_INSTALL_DIRECTORY}' directory first."
    echo
  } >&2
    exit 1
fi

failed_checkout() {
  echo "Failed to git clone $1"
  exit -1
}

checkout() {
  [ -d "$2" ] || git -c advice.detachedHead=0 clone --branch "$3" --depth 1 "$1" "$2" || failed_checkout "$1"
}

if ! command -v git 1>/dev/null 2>&1; then
  echo "ziege: Git is not installed, can't continue." >&2
  exit 1
fi

# Check ssh authentication if USE_SSH is present
if [ -n "${USE_SSH}" ]; then
  if ! command -v ssh 1>/dev/null 2>&1; then
    echo "ziege: configuration USE_SSH found but ssh is not installed, can't continue." >&2
    exit 1
  fi

  # `ssh -T git@github.com' returns 1 on success
  # See https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection
  ssh -T git@github.com 1>/dev/null 2>&1 || EXIT_CODE=$?
  if [[ ${EXIT_CODE} != 1 ]]; then
      echo "ziege: github ssh authentication failed."
      echo
      echo "In order to use the ssh connection option, you need to have an ssh key set up."
      echo "Please generate an ssh key by using ssh-keygen, or follow the instructions at the following URL for more information:"
      echo
      echo "> https://docs.github.com/en/repositories/creating-and-managing-repositories/troubleshooting-cloning-errors#check-your-ssh-access"
      echo
      echo "Once you have an ssh key set up, try running the command again."
    exit 1
  fi
fi

if [ -n "${USE_SSH}" ]; then
  GITHUB="git@github.com:"
else
  GITHUB="https://github.com/"
fi

# Get the code
checkout "${GITHUB}ZerbaZiege/ziege.git" "$ZIEGE_INSTALL_DIRECTORY" "main" &>/dev/null

# Update ~/.zshrc
if [[ ! -e $HOME/.zshrc ]]; then
  touch $HOME/.zshrc
fi

grep -q  '.ziege/init.zsh' $HOME/.zshrc
if [[ $? -ne 0 ]]; then
cat <<EOF >> $HOME/.zshrc
if [[ -d $ZIEGE_INSTALL_DIRECTORY ]] && [[ -e $ZIEGE_INSTALL_DIRECTORY/init.zsh ]]; then
    source $ZIEGE_INSTALL_DIRECTORY/init.zsh
fi
EOF
fi

popd &> /dev/null

which _zg_env &>/dev/null
if [ "$?" != "0" ]; then
  { echo
    echo "WARNING You need to restart your shell"
    echo
  } >&2
fi
