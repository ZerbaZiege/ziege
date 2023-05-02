#!/usr/bin/env zsh

# Ziege VSCode plugin

# _zg_doc "vscode:: v: Run VSCode on the current directory"
function v() {
    if [[ -z "$1" ]]; then
        command code -n .
    else
        command code -n ${@:1}
    fi    
}

