#!/usr/bin/env zsh

# Zeige bootstrap

export ZIEGE_DEBUG=OFF
export ZIEGE_ECHO=OFF
export ZIEGE_GIT_DEBUG=OFF

# _zg_doc "ziege:: _zg_silence: Silence a command. Ignore stdout and stderr."
function _zg_silence() {
    "${@:1}" &> /dev/null
    return $?
}

# _zg_doc "ziege:: _zg_debug: Write a debug message. Controlled by ZIEGE_DEBUG."
function _zg_debug {
    if [[ -n $ZIEGE_DEBUG && $ZIEGE_DEBUG == 'ON' ]]; then
        echo "_zg_debug ${@:1}"
    fi
}

# _zg_doc "ziege:: _zg_debug: Display internal debug message."
function _zg_debug {
    if [[ -n $ZIEGE_DEBUG && $ZIEGE_DEBUG == 'ON' ]]; then
        echo "_zg_debug ${@:1}"
    fi
}

# _zg_doc "ziege:: _zg_echo: Diplay internal message or command. Controlled by ZIEGE_ECHO."
function _zg_echo {
    if [[ -n $ZIEGE_ECHO && $ZIEGE_ECHO == 'ON' ]]; then
        echo "${@:1}"
    fi    
}

# _zg_doc "ziege:: _zg_git_debug: Display internal git debug message. Controlled by ZIEGE_GIT_DEBUG."
function _zg_git_debug {
    if [[ -n $ZIEGE_GIT_DEBUG && $ZIEGE_GIT_DEBUG == 'ON' ]]; then
        echo "_zg_git_debug ${@:1}"
    fi
}

# _zg_doc "ziege:: _zg_env: Set or list environment variables for the Ziege framework."
function _zg_env {
    if [[ -z "$1" ]]; then
        env | grep ZIEGE_
    elif [[ "$1" == "--set" ]]; then
        export ZIEGE_HOME="${ZIEGE_HOME:-$HOME/.ziege}"
        export ZIEGE_PLUGINS_DIR="${ZIEGE_HOME}/plugins" # From the repo
        export ZIEGE_PLUGINS_AVAILABLE_DIR="${ZIEGE_PLUGINS_DIR}/available" # From the repo
        export ZIEGE_PLUGINS_ENABLED_DIR="${ZIEGE_PLUGINS_DIR}/enabled"
        mkdir -p $ZIEGE_PLUGINS_ENABLED_DIR
        export ZIEGE_CACHES="${ZIEGE_HOME}/caches"
        mkdir -p $ZIEGE_CACHES
        export ZIEGE_DOCS_CACHE="${ZIEGE_CACHES}/docs"
        mkdir -p $ZIEGE_DOCS_CACHE
    else
        echo "_zg_env unrecognized option $1"
    fi
}

# _zg_doc "ziege:: _zg_home: Display Ziege home directory."
function _zg_home {
    echo "$ZIEGE_HOME"
}

# _zg_doc "ziege:: _zgg: Go to Ziege home directory."
function _zgg {
    cd $ZIEGE_HOME
}

# _zg_doc "ziege:: _zg_reload: Reload the Ziege framework."
function _zg_reload {
    source $ZIEGE_HOME/init.zsh
}

# _zg_doc "ziege:: _zg_bootstrap: Bootstrap the Ziege framework."
function _zg_bootstrap {

    local _date_stamp
    local _zg_plugin_init_file

    # Make sure environment is set up correctly
    _zg_env --set
    
    _date_stamp=$(date "+%Y%m%d-%H%M%S")
    _zg_debug "_zg_bootstrap $_date_stamp" 

    # Always load zeige plugin init first
    _zg_plugin_init_file="$ZIEGE_PLUGINS_AVAILABLE_DIR/enabled/ziege/init.zsh"

    if [[ -e _zg_plugin_init_file ]]; then
        _zg_debug "Source $_zg_plugin_init_file"
    else
        _zg_debug "ZG full plugin not yet implemented"
        _zg_default_loader
    fi

    if [[ -e $ZIEGE_HOME/.zg_overrides.zsh ]]; then
        source $ZIEGE_HOME/.zg_overrides.zsh
    fi
}

# _zg_doc "ziege:: _zg_default_loader: Default loader for the entire Ziege framework."
function _zg_default_loader {
    # If the full Ziege plugin isn't available
    # Just load everything that's available
    _zg_debug "Running _zg_default_loader"
    
    ls -1R $ZIEGE_PLUGINS_AVAILABLE_DIR/**/init.zsh | \
    while read available_plugin_init_file
    do
        available_plugin_init_dir="${available_plugin_init_file%/*}"
        enabled_plugin_init_dir="${available_plugin_init_dir/available/enabled}"
        enabled_plugin_init_file="$enabled_plugin_init_dir/init.zsh"

        # Enable any plugins found in available dir
        # TODO allow plugin to be skipped
        if [[ -e $available_plugin_init_dir/.skip ]]; then
            # Disable the plugin by removing the link to enabled directory
            _zg_debug "Disabling $available_plugin_init_dir"
            rm -rf $enabled_plugin_init_dir
        else
            # Enable the plugin by ensuring the link to the enable directory exists
            if [[ ! -d $enabled_plugin_init_dir ]]; then
                _zg_debug "Enabling $available_plugin_init_dir"
                ln -s $available_plugin_init_dir $enabled_plugin_init_dir 
            fi
        fi

        # After all this fuss, just load it
        _zg_debug "Loading $enabled_plugin_init_file"
        
        # Leave prompt plugin until the very last
        # grep -q 'prompt' $enabled_plugin_init_file
        # if [[ $? -ne 0 ]]; then
        #     source $enabled_plugin_init_file
        # fi
        
        source $enabled_plugin_init_file
    done 
    
}

# _zg_doc "ziege:: _zg_docs: Generate, cache and display the documentation"
function _zg_docs() {
    local cache_period_seconds=${ZIEGE_DOCS_CACHE_TTL_SECONDS:-86400}
    local docs_cache_date_file="$ZIEGE_DOCS_CACHE/cache_date"
    local docs_cache_file="$ZIEGE_DOCS_CACHE/cache_info"
    local docs_cache_file_formatted="$ZIEGE_DOCS_CACHE/cache_info_formatted"
    local current_date_epoch_seconds=$(date "+%s")

    pushd $ZIEGE_HOME >/dev/null

    if [[ ! -e $docs_cache_date_file ]]; then
        date "+%s" > $docs_cache_date_file
    fi

    cat $docs_cache_date_file | \
    while read last_cache_date_epoch_seconds
    do
        seconds_diff=$(( $current_date_epoch_seconds - $last_cache_date_epoch_seconds ))
        
        if [[ ! -e $docs_cache ]] || [[ $seconds_diff -gt $cache_period_seconds ]]; then
            egrep -R '^[#] _zg_doc' . | \
                cut -d'#' -f2 | \
                sed 's/_zg_doc "//' | \
                sed 's/"//' | \
                sort | uniq > $docs_cache_file

            # Generate pretty command output
            $ZIEGE_HOME/bin/zg_format_docs.zsh
        fi
        if [[ -e $docs_cache_file_formatted ]]; then
            cat $docs_cache_file_formatted
        else
            if [[ -e $docs_cache_file ]]; then
                cat $docs_cache_file
            fi
        fi
        break
    done

    popd >/dev/null   
 
}

# _zg_doc "ziege:: _zg_docs_clear_cache: Clear the documentation cache."
function _zg_docs_clear_cache() {
    rm -rf $ZIEGE_DOCS_CACHE
    mkdir -p $ZIEGE_DOCS_CACHE
}

# _zg_doc "ziege:: _zg_run: (Try) to run a command. Return command presence and status in array _ZG_REPLY"
function _zg_run() {
    cmd="$1"
    which $cmd &> /dev/null
    which_status="$?"
    cmd_status="0"
    if [[ $which_status == "0" ]]; then
        ${@}
        cmd_status="$?"
    fi

    _ZG_REPLY=($which_status $cmd_status)
}

# _zg_doc "ziege:: _zg_os: Detect OS type"
function _zg_os() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo "cygwin"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo "freebsd"
    else
        echo ""
    fi
}

# _zg_doc "ziege:: _zg_open: Open a file"
function _zg_open() {
    local os_type=$(_zg_os)
    local os_open_cmd=""
    
    if [[ -n $os_type ]]; then
        if [[ $os_type == "macos" ]]; then
            os_open_cmd=$(which open)
        else
            os_open_cmd=$(which xdg-open)
        fi
    fi
    if [[ -n $os_open_cmd ]]; then
        $os_open_cmd ${@:1}
    fi
}

# Start everything off
_zg_bootstrap
