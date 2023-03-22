# #!/usr/bin/env zsh

# # Ziege prompt plugin

# Defaults

# formats
# " (%s)-[%b]%u%c-"

# actionformats
# " (%s)-[%b|%a]%u%c-"

+vi-git-untracked() {
  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
      hook_com[misc]+='? '
  else
      hook_com[misc]+=''
  fi
}

setopt PROMPT_SUBST

autoload -Uz vcs_info
precmd() { vcs_info }

# Check for working and staged changes
zstyle ':vcs_info:git:*' check-for-changes yes
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'

zstyle ':vcs_info:git:*' formats '%b %u%c%m'
# Format when the repo is in an action (merge, rebase, etc)
zstyle ':vcs_info:git:*' actionformats "%b (%a) %u%c%m "

# Add Git unstaged
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

PROMPT='%F{cyan}%L %*%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f
$ '


