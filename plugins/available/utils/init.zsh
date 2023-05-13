#!/usr/bin/env zsh

# Ziege Utils plugin

# _zg_doc "utils:: emp: Create an empty directory"
function emp() {
    local dt_stamp=$(date "+%Y%m%d_%H%M%S")
    local base_dir="$HOME/tmp/empty"
    local empty_dir="$base_dir/$dt_stamp"
    mkdir -p $empty_dir
    cd $empty_dir
    if [[ "$1" == "-n" ]]; then
        echo $empty_dir
    else
        v
    fi    
}

# _zg_doc "utils:: _zsh_pseudo_random_number: Create a random number between [1] and [1000]"
function _zsh_pseudo_random_number() {
    local lower_limit=${1:-1}
    local upper_limit=${2:-1000}
    local total_num=0
    local my_rand_num=0
    (( total_num = $upper_limit - $lower_limit + 1 ))
    ((my_rand_num = ($RANDOM % $total_num) + $lower_limit))
    echo $my_rand_num
}

# _zg_doc "utils:: _zsh_prnd: alias for _zsh_pseudo_random_number"
alias _zsh_prnd=_zsh_pseudo_random_number

# _zg_doc "utils:: chmod_zax: alias for chmod a+x *.zsh"
function chmod_zax() {
    chmod a+x *.zsh
}

# _zg_doc "utils:: silence: Silence a command. Send stderr and stdout to /dev/null"
function silence() {
    ${@:1} &>/dev/null
}

# _zg_doc "utils:: pushdq: Silence pushd"
function pushdq() {
    if [[ -n $1 ]]; then
        silence pushd ${@:1}
    fi
}

# _zg_doc "utils:: popdq : Silence popd"
function popdq() {
    silence popd
}

# _zg_doc "utils:: emp_base_dir: Get the base directory for the emp system"
function emp_base_dir() {
    echo "$HOME/tmp/empty"
    #_ZG_REPLY=("$HOME/tmp/empty")
}

# _zg_doc "utils:: emp: Create an empty directory"
function emp() {
    local dt_stamp=$(date "+%Y%m%d_%H%M%S")
    local base_dir=$(emp_base_dir)
    local empty_dir="$base_dir/$dt_stamp"
    mkdir -p $empty_dir
    cd $empty_dir
    if [[ "$1" == "-n" ]]; then
        echo $empty_dir
    else
        v
    fi    
}

# _zg_doc "utils:: empls: Short list of all the empty directories in reverse time order"
function empls() {
    local base_dir=$(emp_base_dir)
    local count= 0
    pushdq $base_dir 
    if [[ -z $1 ]]; then
        count=10
    else
        count=$1
    fi
    for dir in $(ls -1t | head -n $count)
    do
        echo "~/tmp/empty/$dir"
    done
    popdq
}

# _zg_doc "utils:: empll: Long list of all the empty directories in reverse time order"
function empll() {
  local base_dir=$(emp_base_dir)
  pushdq $base_dir
  for dir in $(find . -type d -depth 1 | cut -d'/' -f 2 | sort -r)
  do
    local prefix="~/tmp/empty/$dir"
    pushdq $dir
    ls | wc -l | egrep -q '^[ ]+?0[ ]*?$'
    if (( $? != 0 )); then
      echo $prefix
      for file in $(ls -1)
      do
        echo "$prefix/$file"
      done
    fi
    popdq
  done
  popdq
}

# _zg_doc "utils:: empll: grep output of empll"
function empllg() {
    empll | grep -i ${@:1}
}

# _zg_doc "utils:: emplastdir: Get the lastest empty directory created"
function emplastdir() {
    local base_dir=$(emp_base_dir)
    local count=0
    pushdq $base_dir
    if [[ -z $1 ]]; then
        count=1
    else
        count=$1
    fi

    local latest_dir=$(ls -1t | head -n $count | tail -n 1 )
    echo "$HOME/tmp/empty/$latest_dir"
    popdq
}

# _zg_doc "utils:: emplast: Go to the lastest empty directory created"
function emplast() {
  local latest_dir=$(emplastdir)
  cd $latest_dir
  v
}

# _zg_doc "utils:: emprm: Delete the current emp directory"
function emprm() {
  local current_dir_base=$(basename $(pwd)) 
  cd $(emp_base_dir)
  rm -rf $current_dir_base
}
