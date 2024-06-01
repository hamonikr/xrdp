#!/bin/sh
# xrdp X session start script (c) 2015, 2017, 2021 mirabilos
# published under The MirOS Licence

# Rely on /etc/pam.d/xrdp-sesman using pam_env to load both
# /etc/environment and /etc/default/locale to initialise the
# locale and the user environment properly.

if test -r /etc/profile; then
	. /etc/profile
fi

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

if test -r ~/.bash_profile; then
	. ~/.bash_profile
fi

# multiple session
echo "env -u SESSION_MANAGER -u DBUS_SESSION_BUS_ADDRESS cinnamon-session" > ~/.xsession

# Add Korean Young Key for Remote Session Korean Users in HarmoniKR OS
if [ ! "$DISPLAY" = ":0" ]; then

    # 키보드 레이아웃 확인
    KEYBOARD_LAYOUT=$(setxkbmap -query | grep layout | awk '{print $2}')

    # 101 키보드 레이아웃 처리
    if [ "$KEYBOARD_LAYOUT" = "us" ]; then
        xmodmap -e 'keycode 113 = Hangul'
        xmodmap -e 'keycode 121 = Hangul_Hanja'
    fi

    # 104 키보드 레이아웃 처리
    if [ "$KEYBOARD_LAYOUT" = "kr" ]; then
        xmodmap -e 'keycode 122 = Hangul'
        xmodmap -e 'keycode 121 = Hangul_Hanja'
    fi

	# disable cinnamon 3d accelation
	export CINNAMON_2D=true

	# disable screensaver
	cinnamon-screensaver-command --exit
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-ac "0"
	gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout "0"	
fi

test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession