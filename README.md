# Ziege

"... ziege ... a fish ... the only one in its genus .. "

A lightweight manager and a small set of zsh functions and aliases.
 
## Pre-requisites

There are a minimal set of prerequisites.

* A recent version of zsh. Ziege was developed using zsh 5.8.1.
* A recent version of Python 3. Ziege was developed using Python 3.10.6. Python support is only needed to generate the documentation.
* A recent version of Github CLI ('gh'). Ziege was developed using Github CLI 2.25.0. Github CLI is only needed for the 'gpr' function (Git pull request). 


## Installation

```
# All on one line
curl -s -S -L https://raw.githubusercontent.com/ZerbaZiege/ziege/main/bin/ziege_installer.zsh | zsh

```
## Removal
```

# In ~/.zshrc delete the lines similar to

if [[ -d $ZIEGE_INSTALL_DIRECTORY ]] && [[ -e $ZIEGE_INSTALL_DIRECTORY/init.zsh ]]; then
    source $ZIEGE_INSTALL_DIRECTORY/init.zsh
fi

# In a shell with Ziege enabled
rm -rf $ZIEGE_HOME

```

## Help

Brief command-line help for all current functions is available via the 'zg_help' command or its alias 'help' command.

Help text is cached for 1 day (86400 seconds). The cache period can be changed by setting the environment variable ZIEGE_DOCS_CACHE_TTL_SECONDS.

When the document cache period expires or the document cache is deleted, the help text will be fully regenerated.

To delete the documents cache run:

```
rm -rf $ZIEGE_DOCS_CACHE
```

### Documentation string format

Almost every function in the Ziege framework has a brief documentation string. These documentation strings are extracted, grouped and displayed by the 'zg_help' or 'help' command.

The format is simple. Note the usage of double quotes and colons. Specify those characters exactly as shown below.

```
# _zg_doc "SECTION:: COMMAND: BRIEF DESCRIPTION"

# For instance, the documentation string for 'p' - print the current path - looks like this.

# _zg_doc "path:: p: print the current path"

```

## Plugins

### Plugin structure

PLUGIN_NAME - plugin top-level directory
  README.md
  init.zsh

### Plugin behavior

All plugins are stored in $ZIEGE_HOME/plugins/available.

Plugins are enabled by creating a simlink for the function directory to $ZIEGE_HOME/plugins/enabled.

Plugins are loaded via 'source init.zsh' in the plugin top-level directory.

This process is automatic when ziege is initially loaded.

Note that currently all plugins that are available are automatically enabled.

## Overrides

To override any function in the Ziege framework, create a file

```$ZIEGE_HOME/.zg_overrides.zsh```

If present, this file will be sourced as the very last step in the Ziege bootstrap process.

Of course, you can just find the function in the plugin source and modify it. However, the function will be overwritten by the next update. 

In particular, the following functions, if present, are called in the existing plugins.

### Git SSH support

```
# To specify specific SSH support, set the environment variable GIT_SSH_COMMAND in the function _git_ssh_set
# To disable SSH support, clear the environment variable GIT_SSH_COMMAND in the function _git_ssh_clear

# Examples

function _git_ssh_set() {
   export GIT_SSH_COMMAND="ssh -i ~/.ssh/ziege_rsa" 
}

function _git_ssh_clear() {
    unset GIT_SSH_COMMAND &>/dev/null
}
```

### VPN control

```
# Specify the following functions to start, stop and provide status information:

* _vpn_start
* _vpn_stop
* _vpn_status

# Examples (note these don't actually work for the current versions of Surfshark.)

function _vpn_start() {
    sudo systemctl start surfsharkd2.service
}

function _vpn_stop () {
    sudo systemctl stop surfsharkd2.service
}

function _vpn_status () {
    sudo systemctl status surfsharkd2.service
}

```

