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
  g commit -v -m "${@:1}"    
}

# _zg_doc "git:: gcma: git commit amend with commit message on command line
function gcma() {
  gaa
  g commit --amend -v -m "${@:1}"     
}

# _zg_doc "git:: gb: git list branches
function gb() {
    g branch ${@:1}
}

# _zg_doc "git:: gcwip: git commit all with 'WIP' message
function gcwip() {
    gaa
    if [ -z $1 ]; then
        g commit -v -m 'WIP'
    else
        g commit -v -m "WIP $1"
    fi
}

# _zg_doc "git:: gwip: git commit all with 'WIP' message
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
    _zg_run _git_ssh_set
    
    # Remember to skip the first argument
    g ${@:1}

    _zg_run _git_ssh_clear    
}

# _zg_doc "git:: gpull: update local copy from remote"
function gpull() {
    if [ -z $1 ]; then
        _g_ssh pull origin $(gprimary)
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

# _zg_doc "git:: gco: checkout a branch"
function gco() {
    if [[ -n "$1" ]]; then
        g checkout $1
    fi
}

# _zg_doc "git:: gcom: checkout primary (usually main) branch"
function gcom() {
    local primary_branch
    primary_branch=$(gprimary)
    gco $primary_branch
}

# _zg_doc "git:: gprimary: determine primary (usually main) branch"
function gprimary() {
    # Temporary hack
    g remote show origin | sed -n '/HEAD branch/s/.*: //p'
}

# _zg_doc "git:: gbco: create and checkout a new up-to-date branch"
function gbco() {
    local branch_name
    if [[ -n "$1" ]]; then
        branch_name="$1"
        gcom
        gpull
        gb "$branch_name"
        gco "$branch_name"
    fi
}

# _zg_doc "git:: gbc: get current branch"
function gbc() {
    g branch | grep '^*' | cut -d' ' -f2
}

# _zg_doc "git:: gbc: close current branch"
function gbcl() {
    local branch_to_close
    local primary_branch

    branch_to_close=$(gbc)
    primary_branch=$(gprimary)

    if [[ "$branch_to_close" !=  "$primary_branch" ]]; then
        gcom
        gpull
        gb -D $branch_to_close
    fi
}

# _zg_doc "git:: gcl: git clone the specified repository"
function gcl() {
    g clone ${@:1}
}

# _zg_doc "git:: gpr: Create new Github pull request"
function gpr() {
    local branch_name
    local commit_message
    local gh_bin
    local gh_tmp_out

    #set -x
    if [[ -z "$1" ]]; then
        echo "Usage: gpr BRANCH_NAME COMMIT_MESSAGE"
    else
        branch_name="$1"
        shift
        if [[ -z "$1" ]]; then
            echo "Usage: missing commit message"
        else
            commit_message="$1"
            gst | grep -q 'working tree clean'
            if [[ $? -ne 0 ]]; then
                gcm "${branch_name}: ${commit_message}"
            fi
            gpush origin $(gbc)
            gh_bin=$(which gh)
            if [[ -z "$gh_bin" ]]; then
                echo "You will need to complete the pull request manually for $(gbc)"
                echo "Github CLI tools required for automated PR creation"
                echo "Install from https://github.com/cli/cli"
            else
                gh_tmp_out="$HOME/tmp/gpr.out"
                gh pr create --title "${branch_name}: ${commit_message}" --body "Completed" | tee $gh_tmp_out
                xdg-open $(cat $gh_tmp_out) |& >/dev/null
            fi
        fi
    fi
    # set +x     
}

