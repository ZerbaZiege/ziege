# Ziege CLI plugin

# _zg_doc "ls:: l: ls -1 - short ls list"
function l() {
    command ls -1 ${@:1}
}

# _zg_doc "ls:: la: ls -1a - short ls list with .dotfiles"
function la() {
    command ls -1 -a ${@:1}
}

# _zg_doc "ls:: ll: ls -l - long list"
function ll() {
    command ls -l ${@:1}
}

# _zg_doc "ls:: lla: ls -al - long ls list with .dotfiles"
function lla() {
    command ls -la ${@:1}
}

# _zg_doc "ls:: lth: ls -1t - most recent n entries"
function lth() {
    local total_lines
    if [[ -z "$1" ]]; then
        total_lines="10"
    else
        total_lines="$1"
    fi
    command ls -1t | head -n $total_lines
}

# _zg_doc "ls:: lg: find in ls -1t output"
function lg() {
    if [[ ! -z "$1" ]]; then
        command ls -1t | grep -i "$1" 
    fi
}


# Go to specific directories

# _zg_doc "cd:: tmp: cd to $HOME/tmp"
function tmp() {
    cd $HOME/tmp
}

# _zg_doc "cd:: down: cd to $HOME/Downloads"
function down() {
    cd $HOME/Downloads
}

# _zg_doc "cd:: proj: cd to $HOME/Downloads"
function proj() {
    cd $HOME/Projects
}

# _zg_doc "cd:: goext: cd to $HOME/Projects/external"
function goext() {
    cd $HOME/Projects/external
}

# _zg_doc "ps:: fps: find in ps output"
function fps() {
    local ps_options="alx"

    ps $ps_options | head -1

    if [[ -z "$1" ]]; then
        ps $ps_options 
    else
        ps $ps_options | grep -i $1
    fi
}

# _zg_doc "help:: zg_help: print this short command help"
function zg_help() {
    _zg_docs
}

# _zg_doc "help:: help: print this short command help"
function help() {
    _zg_docs
}

# _zg_doc "history:: h: history"
function h() {
    local total_lines
    if [[ -z "$1" ]]; then
        total_lines=100
    else
        total_lines=$1
    fi
    fc -l  -${total_lines}
}

# _zg_doc "history:: hf: find in history"
function hf() {
    local total_lines=1000
    local output_lines=100
    if [[ -n "$1" ]]; then
        h $total_lines | egrep -i $1 | tail -n $output_lines
    fi
}

# _zg_doc "url:: url_encode: url encode a string"
function url_encode() {
    if [[ -n "$1" ]]; then
        python3 -c "from urllib.parse import quote; print(quote(\"${1-''}\"))"
    fi
}

# _zg_doc "path:: p: print the current path"
function p() {
    echo "$PATH"
}
