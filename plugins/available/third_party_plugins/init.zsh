#!/usr/bin/env zsh

# Ziege Load third-party plugins

# _zg_doc "third_party:: _tp_autoload_plugins: Autoload third-party plugins installed in ~/.zsh"
function  _tp_autoload_plugins() {
    local tp_plugin_name
    local tp_plugin_dir
    local tp_plugin_init_file
    local tp_plugin_init_path
    
    export ZIEGE_ZSH_THIRD_PARTY_PLUGINS_DIR=${ZIEGE_THIRD_PARTY_PLUGINS_DIR:-$HOME/.zsh}

    typeset -A tp_plugins
    tp_plugins[zsh-autosuggestions]="zsh-autosuggestions.zsh"

    for tp_plugin_name in "${(@k)tp_plugins}"; do
        tp_plugin_dir=${ZIEGE_ZSH_THIRD_PARTY_PLUGINS_DIR}/${tp_plugin_name}
        tp_plugin_init_file=$tp_plugins[${tp_plugin_name}]
        tp_plugin_init_path=${tp_plugin_dir}/${tp_plugin_init_file}
        if [[ -e $tp_plugin_init_path ]]; then
            source $tp_plugin_init_path
        fi
    done
}

_tp_autoload_plugins
