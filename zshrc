PROMPT=$'%{\e[0;36m%}%n@%{\e[1;36m%}%m %{\e[0;36m%}%~ %{\e[0;37m%}$'
TERM=xterm-256color
. ~/.zsh/config
. ~/.zsh/aliases
. ~/.zsh/completion
 
# use .localrc for settings specific to one system
[[ -f ~/.localrc ]] && . ~/.localrc
