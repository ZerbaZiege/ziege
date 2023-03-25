#!/usr/bin/env zsh

# Ziege Git plugin

# _zg_doc "git:: g: Issue any git command"
function g {
    # Remember to skip the first argument
    # _zg_echo "command git ${@:1}"
    command git ${@:1}
}

# _zg_doc "git:: gst: git status"
function gst {
    g status
}

# _zg_doc "git:: gaa: git add all uncommitted files"
function gaa {
    g add --all
}

# _zg_doc "git:: gcm: git commit with commit message on command line"
function gcm() {
  gaa
  g commit -v -m "\"${@:1}\""    
}

# _zg_doc "git:: gcma: git commit amend with commit message on command line
function gcma() {
  gaa
  g commit --amend -v -m "\"${@:1}\""     
}

# _zg_doc "git:: gb: git list branches
function gb() {
    g branch 
}

# _zg_doc "git:: gcwip: git commit with 'WIP' message
function gcwip() {
    gaa
    if [ -z $1 ]; then
        g commit -v -m 'WIP'
    else
        g commit -v -m "WIP $1"
    fi
}

# _zg_doc "git:: gwip: git commit with 'WIP' message
function gwip() {
    if [ -z $1 ]; then
        gcwip
    else
        gcwip "$1"
    fi    
}

# _zg_doc "git:: gl: git display (paginated) log
function gl() {
    g log "$@"
}

# _zg_doc "git:: glo: git show brief one-line log
function glo() {
    g log --oneline "$@"
}

# _zg_doc "git:: gconf: git display 'nearest' .git/config file
function gconf() {
    cat "$(g rev-parse --git-dir)/config"
    # local git_config_name='.git/config'
    # local current_dir=$(pwd)

    # while :
    # do
    #     if [[ -e $current_dir/$git_config_name ]]; then
    #         echo "loc: $current_dir/$git_config_name\n"
    #         cat "$current_dir/$git_config_name"
    #         break
    #     fi
    #     current_dir=$(dirname $current_dir)
    # done
}

# _zg_doc "git:: gs: show contents of a commit"
function gs() {
    g show "$1"
}

# _zg_doc "git:: _g_ssh: (internal) wrapper for any Git command that requires SSH
function _g_ssh() {
    git_ssh_config_file=".git_ssh.conf"
    git_ssh_clear_config_file=".git_ssh_clear.conf"
    repository_root=$(command git rev-parse --show-toplevel)
    
    if [[ -e $repository_root/$git_ssh_config_file ]]; then
        source $repository_root/$git_ssh_config_file
    fi
    
    # Remember to skip the first argument
    g ${@:1}
    
    if [[ -e $repository_root/$git_ssh_clear_config_file ]]; then
        source $repository_root/$git_ssh_clear_config_file
    fi
}

# _zg_doc "git:: gpull: update local copy from remote"
function gpull() {
    if [ -z $1 ]; then
        _g_ssh pull origin main
    else
        _g_ssh pull ${@:1}
    fi
}

# _zg_doc "git:: gpush: push local copy to remote"
function gpush() {
    if [ -z $1 ]; then
        _g_ssh push origin main --tags
    else
        _g_ssh push ${@:1} --tags
    fi
}

# _zg_doc "git:: gpushf: force push local copy to remote"
function gpushf() {
    if [ -z $1 ]; then
        _g_ssh push -f origin main --tags
    else
        _g_ssh push -f  ${@:1} --tags
    fi 
}

# _zg_doc "git:: gsq: squeeze designated commits into one"
function gsq() {
    if [ -n $1 ]; then
        g rebase --interactive "$1"
    fi 
}

