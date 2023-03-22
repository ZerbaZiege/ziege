#!/usr/bin/env zsh

# Ziege VSCode plugin

# _zg_doc "vscode:: v: Run VSCcode on the current directory"
function v() {
    if [[ -z "$1" ]]; then
        command code .
    else
        command code  ${@:1}
    fi    
}

