#!/usr/bin/env bash
#
# This script is an example. You might need to edit this script
# depending on your distro if it doesn't work for you.
#
# Uncomment the following line for debug:
# exec xterm


# Execution sequence for interactive login shell - pseudocode
#
# IF /etc/profile is readable THEN
#     execute /etc/profile
# END IF
# IF ~/.bash_profile is readable THEN
#     execute ~/.bash_profile
# ELSE
#     IF ~/.bash_login is readable THEN
#         execute ~/.bash_login
#     ELSE
#         IF ~/.profile is readable THEN
#             execute ~/.profile
#         END IF
#     END IF
# END IF
pre_start()
{
  if [ -r /etc/profile ]; then
    . /etc/profile
  fi
  if [ -r ~/.bash_profile ]; then
    . ~/.bash_profile
  else
    if [ -r ~/.bash_login ]; then
      . ~/.bash_login
    else
      if [ -r ~/.profile ]; then
        . ~/.profile
      fi
    fi
  fi
  return 0
}

# When logging out from the interactive shell, the execution sequence is:
#
# IF ~/.bash_logout exists THEN
#     execute ~/.bash_logout
# END IF
post_start()
{
  if [ -r ~/.bash_logout ]; then
    . ~/.bash_logout
  fi
  return 0
}

get_xdg_session_startupcmd()
{
  # If DESKTOP_SESSION is set and valid then the STARTUP command will be taken from there
  # GDM exports environment variables XDG_CURRENT_DESKTOP and XDG_SESSION_DESKTOP.
  # This follows it.
  if [ -n "$1" ] && [ -d /usr/share/xsessions ] \
    && [ -f "/usr/share/xsessions/$1.desktop" ]; then
    STARTUP=$(grep ^Exec= "/usr/share/xsessions/$1.desktop")
    STARTUP=${STARTUP#Exec=*}
    XDG_CURRENT_DESKTOP=$(grep ^DesktopNames= "/usr/share/xsessions/$1.desktop")
    XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP#DesktopNames=*}
    XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP//;/:}
    export XDG_CURRENT_DESKTOP
    export XDG_SESSION_DESKTOP="$DESKTOP_SESSION"
  fi
}

#start the window manager
wm_start()
{
  if [ -r /etc/default/locale ]; then
    . /etc/default/locale
    export LANG LANGUAGE
  fi

  # debian
  if [ -r /etc/X11/Xsession ]; then
    pre_start

    # if you want to start preferred desktop environment,
    # add following line,
    #  [ -n "$XRDP_SESSION" ] && export DESKTOP_SESSION=<your preferred desktop>
    # in either of following file.
    # 1. ~/.profile
    # 2. create a file (any_filename.sh is OK) in /etc/profile.d
    # <your preferred desktop> shall be one of "ls -1 /usr/share/xsessions/|cut -d. -f1"
    # e.g.  [ -n "$XRDP_SESSION" ] && export DESKTOP_SESSION=ubuntu

    # STARTUP is the default startup command.
    # if $1 is empty and STARTUP was not set
    # /etc/X11/Xsession.d/50x11-common_determine-startup will fallback to
    # x-session-manager
    if [ -z "$STARTUP" ] && [ -n "$DESKTOP_SESSION" ]; then
      get_xdg_session_startupcmd "$DESKTOP_SESSION"
    fi

    . /etc/X11/Xsession
    post_start
    exit 0
  fi

  # alpine
  # Don't use /etc/X11/xinit/Xsession - it doesn't work
  if [ -f /etc/alpine-release ]; then
    if [ -f /etc/X11/xinit/xinitrc ]; then
        pre_start
        /etc/X11/xinit/xinitrc
        post_start
    else
        echo "** xinit package isn't installed" >&2
        exit 1
    fi
  fi

  # el
  if [ -r /etc/X11/xinit/Xsession ]; then
    pre_start
    . /etc/X11/xinit/Xsession
    post_start
    exit 0
  fi

  # suse
  if [ -r /etc/X11/xdm/Xsession ]; then
    # since the following script run a user login shell,
    # do not execute the pseudo login shell scripts
    . /etc/X11/xdm/Xsession
    exit 0
  elif [ -r /usr/etc/X11/xdm/Xsession ]; then
    . /usr/etc/X11/xdm/Xsession
    exit 0
  fi

  pre_start
  xterm
  post_start
}

# hamonikr
if [ -r /etc/hamonikr/info ]; then
  pre_start

  # if you want to start preferred desktop environment,
  # add following line,
  #  [ -n "$XRDP_SESSION" ] && export DESKTOP_SESSION=<your preferred desktop>
  # in either of following file.
  # 1. ~/.profile
  # 2. create a file (any_filename.sh is OK) in /etc/profile.d
  # <your preferred desktop> shall be one of "ls -1 /usr/share/xsessions/|cut -d. -f1"
  # e.g.  [ -n "$XRDP_SESSION" ] && export DESKTOP_SESSION=ubuntu

  # locale
  if test -r /etc/default/locale; then
    . /etc/default/locale
    test -z "${LANG+x}" || export LANG
    test -z "${LANGUAGE+x}" || export LANGUAGE
    test -z "${LC_ADDRESS+x}" || export LC_ADDRESS
    test -z "${LC_ALL+x}" || export LC_ALL
    test -z "${LC_COLLATE+x}" || export LC_COLLATE
    test -z "${LC_CTYPE+x}" || export LC_CTYPE
    test -z "${LC_IDENTIFICATION+x}" || export LC_IDENTIFICATION
    test -z "${LC_MEASUREMENT+x}" || export LC_MEASUREMENT
    test -z "${LC_MESSAGES+x}" || export LC_MESSAGES
    test -z "${LC_MONETARY+x}" || export LC_MONETARY
    test -z "${LC_NAME+x}" || export LC_NAME
    test -z "${LC_NUMERIC+x}" || export LC_NUMERIC
    test -z "${LC_PAPER+x}" || export LC_PAPER
    test -z "${LC_TELEPHONE+x}" || export LC_TELEPHONE
    test -z "${LC_TIME+x}" || export LC_TIME
    test -z "${LOCPATH+x}" || export LOCPATH
  fi

  # multiple session
  echo "env -u SESSION_MANAGER -u DBUS_SESSION_BUS_ADDRESS cinnamon-session" > ~/.xsession

  # Add Korean Young Key for Remote Session Korean Users in HarmoniKR OS
  if [ ! "$DISPLAY" = ":0" ]; then
    xmodmap -e 'keycode 122 = Hangul'
    xmodmap -e 'keycode 121 = Hangul_Hanja'
    export CINNAMON_2D=true
  fi

  # disable cinnamon screensaver
  cinnamon-screensaver-command --exit
  gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-ac "0"
  gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout "0"

  # STARTUP is the default startup command.
  # if $1 is empty and STARTUP was not set
  # /etc/X11/Xsession.d/50x11-common_determine-startup will fallback to
  # x-session-manager
  if [ -z "$STARTUP" ] && [ -n "$DESKTOP_SESSION" ]; then
    get_xdg_session_startupcmd "$DESKTOP_SESSION"
  fi

  . /etc/X11/Xsession
  post_start
  exit 0
fi

#. /etc/environment
#export PATH=$PATH
#export LANG=$LANG

# change PATH to be what your environment needs usually what is in
# /etc/environment
#PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
#export PATH=$PATH

# for PATH and LANG from /etc/environment
# pam will auto process the environment file if /etc/pam.d/xrdp-sesman
# includes
# auth       required     pam_env.so readenv=1

wm_start

exit 1
