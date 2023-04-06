# Ziege

"... ziege ... a fish ... the only one in its genus .. "

A lightweight manager for zsh aliases etc.

## Installation

```
export ZIEGE_HOME="$HOME/.ziege"
mkdir -p $ZIEGE_HOME
cd $ZIEGE_HOME
#TODO Clone Git repo into $ZIEGE_HOME
#TODO $ZIEGE_HOME/ziege_install.zsh
```

```
Temporary

In ~/.zshrc

# Ziege manual installation
if [[ -d $HOME/.ziege ]] && [[ -e $HOME/.ziege/init.zsh ]]; then
    source $HOME/.ziege/init.zsh
fi

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

  
## Overrides

To override any function in the Ziege framework, create a file

```$ZIEGE_HOME/.zg_overrides.zsh```

If present, this file will be sourced as the very last step in the Ziege bootstrap process.

Of course, you can just find the function in the plugin source and modify it. However, the function will be overwritten by the next update. 


