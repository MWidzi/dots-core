# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#history
unsetopt HIST_SAVE_NO_DUPS

#completion
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

#stack
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt AUTO_CD              # Auto cd when entering a directory name.

#path
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin"

# git aliases
alias gc='git commit -m'
alias gpl='git pull'
alias ga='git add'
alias gps='git push'
alias gfps='git push --force-with-lease'
alias gr='git rebase'
alias gm='git merge'
alias gcl='git clone'
alias gb='git branch -c'
alias gbd='git branch -D'
alias gs='git switch'

# other aliases
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

#navigation
bindkey -v
export KEYTIMEOUT=1

source /home/widzi/.config/zsh/cursor_mode
autoload -U cursor_mode; cursor_mode

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd m edit-command-line

#variables
export FZF_DEFAULT_OPTS_FILE=~/.config/fzf/.fzfrc
export FZF_DEFAULT_COMMAND="
fd --type f --hidden -E .steam -E Steam
"
export FZF_CTRL_T_COMMAND="
fd --type f --hidden -E .steam -E Steam
"

export MPD_HOST=$HOME/.local/share/mpd/socket

#syntax highlighting
[[ -f ~/.config/zsh/theme.zsh ]] && source ~/.config/zsh/theme.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS+=(main brackets)

#sources
source /home/widzi/.config/zsh/text_objects.zsh
source /home/widzi/.config/zsh/plugins/bd/bd.zsh

source <(fzf --zsh)
bindkey -r '^T'                  # unbind Ctrl+t
bindkey '^F' fzf-file-widget     # bind Ctrl+f to fzf

source /home/widzi/.config/zsh/completion.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# zsh autosuggest config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^L' autosuggest-accept

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"

  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function v() {
  nvim "$@"
}

# To customize prompt, run `p10k configure` or edit ~/inabashell/zsh/.p10k.zsh.
[[ ! -f ~/inabashell/zsh/.p10k.zsh ]] || source ~/inabashell/zsh/.p10k.zsh
