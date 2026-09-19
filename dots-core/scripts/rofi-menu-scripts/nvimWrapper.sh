export FZF_DEFAULT_COMMAND="
    fd --type f --hidden -E .steam -E Steam
"

fzf_args=(
  --height 100%
    --list-border rounded
    --input-border rounded
    --header-border rounded
    --layout reverse
    --scroll-off=200
    --padding 1,2
    --input-label 'Input'
    --bind 'result:transform-list-label:
    if [[ -z \$FZF_QUERY ]]; then
    echo \" \$FZF_MATCH_COUNT items \";
    else echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \";
    fi'
    --bind 'ctrl-r:change-list-label(Reloading the list)+reload(sleep 2; git ls-files)'
    --color 'border:#c7c7c7,label:#f3f3f3'
    --color 'list-border:#c7c7c7,list-label:#f3f3f3'
    --color 'input-border:#c7c7c7,input-label:#f3f3f3'
    --color 'prompt:#b2b2b2,info:#c7c7c7'
    --color 'bg:#343434,bg+:#343434,hl:#858585,hl+:#858585,pointer:#454545'
)

path=$(fd --type d --hidden -E .steam -E Steam 2> /dev/null | fzf "${fzf_args[@]}")

cd $path
nvim 

exec zsh
