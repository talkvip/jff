# enable color support of ls and also add handy aliases
function check_color_support () {
    if which dircolors >/dev/null 2>&1; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias dir='dir --color=auto'
        alias vdir='vdir --color=auto'
    fi
}

check_color_support

# For BSD colorful commands: ls
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
#export TERM=xterm-color

# always enable colorful grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Reference: procps-3.2.7/ps/output.c:1575
#   {"Std_f",    "uid_hack,pid,ppid,c,stime,tname,time,cmd"},                     /* new -f */
#
# uid_hack's width is 8 by default, which is often too short.
# (procps-3.2.7/proc/pwcache.h:10:#define P_G_SZ 20)
#
alias psf='ps -ouid_hack:20,pid,ppid,c,stime,tname,time,cmd'
alias apt='aptitude -F "%c%a%M%T %40p %20V %v %R:%12s %r %D %I - %60d" -w `stty size | sed "s/.* //"`'

alias newsmth='luit -encoding GBK bbs.sh'
alias minicom='minicom -w'

alias cp='cp -i'
alias mv='mv -i'
[ -w /opt/$USER ] && export TRASH_DIR=/opt/$USER/Trash
[ -f $HOME/bin/safe_rm.sh ] && . $HOME/bin/safe_rm.sh

alias c=clear

export ACK_PAGER="less -R"
which ack-grep >/dev/null 2>&1 && alias ack=ack-grep

alias locallib='eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"'

alias initfink='which fink >/dev/null 2>&1 || { export PROMPT_COMMAND="echo -n \(fink\)\ "; . /sw/bin/init.sh; check_color_support; }'
alias initpkgsrc='which bmake >/dev/null 2>&1 || { export PROMPT_COMMAND="echo -n \(pkgsrc\)\ "; export PATH=$HOME/pkg/gnu/bin:$HOME/pkg/bin:$HOME/pkg/sbin:$PATH; check_color_support; }'
alias initmacports='which port >/dev/null 2>&1 || { export PROMPT_COMMAND="echo -n \(macports\)\ "; export PATH=$HOME/macports/libexec/gnubin:$HOME/macports/bin:$HOME/macports/sbin:$PATH; check_color_support; }'
alias inithomebrew='which brew >/dev/null 2>&1 || { export PROMPT_COMMAND="echo -n \(homebrew\)\ "; export PATH=$HOME/homebrew/bin:$HOME/homebrew/sbin:$PATH; brew --prefix coreutils >/dev/null 2>&1 && export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH; check_color_support; }'
alias initgentoo=~/gentoo/startprefix
# ~/gentoo/etc/bash/bashrc sets PROMPT_COMMAND, so I have to set it again here:
which emerge >/dev/null 2>&1 && export PROMPT_COMMAND="echo -n \(gentoo\)\ ";

alias initboot2docker='eval "$(boot2docker shellinit)"'
alias initchef='eval "$(chef shell-init bash)"'

alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'
alias gs='git status'
alias gl='git log'
alias gk='gitk --all'

function u () {
    if expr "$1" : "[1-9][0-9]*$" >/dev/null; then
        local arg="$1" s=..
        while [ $((--arg)) -gt 0 ]; do
            s="$s/.."
        done
        cd $s
    else
        local i=$(expr "$PWD" : ".*$1") j
        if [ $i -gt 0 ]; then
            j=$(expr index "$(expr substr "$PWD" $((++i)) 10000)" /)
            [ $j -gt 0 ] && cd "$(expr substr "$PWD" 1 $((i+j)))"
        else
            echo "ERROR: can't find \"$1\" in \"$PWD\"!" >&2
        fi
    fi
}

# for j() function
[ -f $HOME/bin/jump.sh ] && . $HOME/bin/jump.sh

function ranger-cd () {
    local before after
    before="$(pwd)"
    ranger --fail-unless-cd "$@" || return 0
    after="$(grep \^\' ~/.config/ranger/bookmarks | cut -b3-)"
    if [[ "$before" != "$after" ]]; then
      cd "$after"
    fi
}
bind '"\C-k":"ranger\C-m"'
bind '"\C-o":"ranger-cd\C-m"'

