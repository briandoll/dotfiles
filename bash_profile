source ~/.git-prompt.sh
source ~/.bash/aliases
source ~/.bash/completions
source ~/.bash/paths
source ~/.bash/config
source ~/.bash/functions

JAVA_HOME=/usr/bin/java

if [ -f ~/.bash.local ]; then
  . ~/.bash.local
fi

if [ -f /opt/local/etc/bash_completion ]; then
  . /opt/local/etc/bash_completion
fi

# rvm
if [[ -s /Users/briandoll/.rvm/scripts/rvm ]] ; then source /Users/briandoll/.rvm/scripts/rvm ; fi
