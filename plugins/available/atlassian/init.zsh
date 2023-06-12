# Ziege Atlassian plugin

# _zg_doc "atlassian:: jo: open a Jira ticket from the command line - Define _ZG_JIRA_URL"
function jo() {
    if [[ -n $1 ]] && [[ -n $_ZG_JIRA_URL ]]; then
        _zg_open $_ZG_JIRA_URL/browse/$1
    fi
}
