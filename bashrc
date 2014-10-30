# .bashrc file
# Last Updated 07/13/13

# -----------------------------------
# -- 1.1) Set up umask permissions --
# -----------------------------------
#  The following incantation allows easy group modification of files.
#  See here: http://en.wikipedia.org/wiki/Umask
#
#     umask 002 allows only you to write (but the group to read) any new
#     files that you create.
#
#     umask 022 allows both you and the group to write to any new files
#     which you make.
#
#  In general we want umask 022 on the server and umask 002 on local
#  machines.
#
#  The command 'id' gives the info we need to distinguish these cases.
#
#     $ id -gn  #gives group name
#     $ id -un  #gives user name
#     $ id -u   #gives user ID
#
#  So: if the group name is the same as the username OR the user id is not
#  greater than 99 (i.e. not root or a privileged user), then we are on a
#  local machine (check for yourself), so we set umask 002.
#
#  Conversely, if the default group name is *different* from the username
#  AND the user id is greater than 99, we're on the server, and set umask
#  022 for easy collaborative editing.
if [ "`id -gn`" == "`id -un`" -a `id -u` -gt 99 ]; then
	umask 002
else
	umask 022
fi


# ---------------------------------------------------------
# -- 1.2) Set up bash prompt and ~/.bash_eternal_history --
# ---------------------------------------------------------
#  Set various bash parameters based on whether the shell is 'interactive'
if [ "$PS1" ]; then

    if [ -x /usr/bin/tput ]; then
      if [ "x`tput kbs`" != "x" ]; then # We can't do this with "dumb" terminal
        stty erase `tput kbs`
      elif [ -x /usr/bin/wc ]; then
        if [ "`tput kbs|wc -c `" -gt 0 ]; then # We can't do this with "dumb" terminal
          stty erase `tput kbs`
        fi
      fi
    fi
    case $TERM in
	xterm*)
		if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
		else
	    	PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"'
		fi
		;;
	screen)
		if [ -e /etc/sysconfig/bash-prompt-screen ]; then
			PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
		else
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"'
		fi
		;;
	*)
		[ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default

	    ;;
    esac

    # Bash eternal history
    # --------------------
    # This snippet allows infinite recording of every command you've ever
    # entered on the machine, without using a large HISTFILESIZE variable,
    # and keeps track if you have multiple screens and ssh sessions into the
    # same machine. It is adapted from:
    # http://www.debian-administration.org/articles/543.
    #
    # The way it works is that after each command is executed and
    # before a prompt is displayed, a line with the last command (and
    # some metadata) is appended to ~/.bash_eternal_history.
    #
    # This file is a tab-delimited, timestamped file, with the following
    # columns:
    #
    # 1) user
    # 2) hostname
    # 3) screen window (in case you are using GNU screen)
    # 4) date/time
    # 5) current working directory (to see where a command was executed)
    # 6) the last command you executed
    #
    # The only minor bug: if you include a literal newline or tab (e.g. with
    # awk -F"\t"), then that will be included verbatime. It is possible to
    # define a bash function which escapes the string before writing it; if you
    # have a fix for that which doesn't slow the command down, please submit
    # a patch or pull request.

    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo -e $$\\t$USER\\t$HOSTNAME\\tscreen $WINDOW\\t`date +%D%t%T%t%Y%t%s`\\t$PWD"$(history 1)" >> ~/.bash_eternal_history; history -a'

    # Update Prompt from default to something useful
    # All the colors below can be changed to their bold counterparts by changing the '0;' to '1;' 
    # See: http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html

	# Function to grab the current git branch, if in a git repository - used in prompt below
	function parse_git_branch {
		command -v git > /dev/null && ref=$(git symbolic-ref HEAD 2> /dev/null) && echo "["${ref#refs/heads/}"]"
	}

	# Designed to be called with an optional paramter, which overrides the HOSTCOLOR
	# That way, in your bashrc_custom, you can declare a different color if the defaults
	# below don't work for you

	function prompt {
		local BLACK="\[\033[0;30m\]"
		local RED="\[\033[0;31m\]"
		local GREEN="\[\033[0;32m\]"
		local YELLOW="\[\033[0;33m\]"
		local BLUE="\[\033[0;34m\]"
		local PURPLE="\[\033[0;35m\]"
		local CYAN="\[\033[0;36m\]"
		local GREY="\[\033[0;37m\]"
		local DEFAULT="\[\033[0m\]"

		local HOSTCOLOR="$RED"
		[ `echo $HOSTNAME | grep -i dev` ] && HOSTCOLOR="$GREEN"
		[ `echo $HOSTNAME | grep -i qa` ] && HOSTCOLOR="$YELLOW"
		[ `echo $HOSTNAME | grep -i stag` ] && HOSTCOLOR="$YELLOW"

		if [ -n "$1" ]; then
			HOSTCOLOR=$1
		fi

		export PS1="\n[$CYAN\u$WHITE@$HOSTCOLOR\h$DEFAULT: \w] $GREY\$(parse_git_branch)$DEFAULT\n$ "
    }
    prompt

    if [ "x$SHLVL" != "x1" ]; then # We're not a login shell
        for i in /etc/profile.d/*.sh; do
	    if [ -r "$i" ]; then
	        . $i
	    fi
	done
    fi
fi



## ------------------------------------------------
## -- 1.3) Set Traditional Bash History Settings --
## ------------------------------------------------

# Append to history rather than clobbering it
export HISTSIZE=2000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups
export HISTIGNORE='jobs:fg:bg:exit:ll:du:df:cd:..:...'
export HISTTIMEFORMAT='%b/%d/%y - %H:%M:%S '
shopt -s histappend

## ------------------------------
## -- 1.4) Bash Color Settings --
## ------------------------------

# Mac OS X
export CLICOLOR=1
export LSCOLORS=ExGxCxDxcxegedabagacad

# Everything else
export LS_COLORS='no=00:fi=00:di=00;94:ln=00;36:pi=40;33:so=00;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=00;32:*.cmd=00;32:*.exe=00;32:*.com=00;32:*.btm=00;32:*.bat=00;32:*.sh=00;32:*.csh=00;32:*.tar=00;31:*.tgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.bz=00;31:*.tz=00;31:*.rpm=00;31:*.cpio=00;31:*.jpg=00;35:*.gif=00;35:*.bmp=00;35:*.xbm=00;35:*.xpm=00;35:*.png=00;35:*.tif=00;35:'

## ---------------------------------
## -- 1.5) Set Misc Bash Settings --
## ---------------------------------
# See:  http://www.ukuug.org/events/linux2003/papers/bash_tips/

# Turn on checkwinsize (checks for a window resize after each command and adjust columns accordingly)
shopt -s checkwinsize

# Correct for Minor Misspellings when Changing Directories
shopt -s cdspell

# Must Ctrl+D twice to end session
export IGNOREEOF=1

## -----------------------
## -- 2) Set up aliases --
## -----------------------

# 2.1) Listing, directories, and motion

case $OSTYPE in
    linux-gnu) alias ll='ls -lAh --color';;
    darwin*)   alias ll='ls -lAGh';;
esac

alias la="ls -A"
alias m='less'
alias ..='cd ..'
alias ...='cd ..;cd ..'
alias du='du -ch -d=1'
alias treeacl='tree -A -C -L 2'

# 2.2) Text and editor commands
alias vi='vim'
alias em='emacs -nw'     # No X11 windows
alias eqq='emacs -nw -Q' # No config and no X11
export EDITOR='vim'
export VISUAL='vim' 

# 2.3) grep options
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32' # green for matches

# 2.4) sort options
# Ensures cross-platform sorting behavior of GNU sort.
# http://www.gnu.org/software/coreutils/faq/coreutils-faq.html#Sort-does-not-sort-in-normal-order_0021
unset LANG
export LC_ALL=POSIX

## ------------------------------
## -- 3) User-customized code  --
## ------------------------------

## Define any location/machine specific variables you want in bashrc_custom
[ -f ~/.dotfiles/bashrc_custom ] && source ~/.dotfiles/bashrc_custom
