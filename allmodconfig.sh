#!/bin/bash

#----------------------------------------------------------------------------
# allmodconfig.sh
# Copyright (C) 2013 Nathan Shearer
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 as published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to:
#   The Free Software Foundation Inc.
#   51 Franklin Street
#   Fifth Floor
#   Boston, MA
#   02110-1301
#   USA

NAME="allmodconfig"
CODENAME="allmodconfig"
COPYRIGHT="Copyright (C) 2013 Nathan Shearer"
VERSION="1.0.0.0"

# \brief Ensures dependencies are present
# \param $@ The dependencies to check for
function shearer_check_dependencies
{
	for TOOL in "$@"; do
		if ! type "$TOOL" >/dev/null 2>/dev/null; then
			echo "$CODENAME: \"$TOOL\" is required for this application to work correctly." >&2
			exit
		fi
	done
}

# \brief Sends an email
# \param $1 The e-mail address
# \param $2 The subject
# \param $3 The message
function shearer_email
{
	echo "shearer_email" "$@" >> "$LOG"
	cat "$3" | mail -s "$2" "$1"
}

# \brief Cleans up the environment and exits
# \param $1 The exit code
# \param $2 The exit message
#
# If DEBUG=true then temporary files are not deleted.
function shearer_exit
{
	echo "shearer_exit" "$@" >>"$LOG"
	local EXIT="$1"
	local MESSAGE="$2"
	if [ "$EXIT" = "" ]; then
		EXIT=0
	fi
	if [ "$MESSAGE" = "" ]; then
		MESSAGE="An unrecoverable error has occurred"
	fi
	if ! $DEBUG; then
		rm -rf "$TMP"
	else
		printf "Debug mode is enabled. Temporary files in \"$TMP\" will *not* be deleted.\n"
	fi
	case $EXIT in
		0) exit;;
		*) echo "$CODENAME: $MESSAGE.\n" >&2; exit $EXIT;;
	esac
}

# \brief Displays the help and exits the program
function shearer_help
{
	printf "Enables all possible kernel modules.\n\n"
	printf "Usage:\n"
	printf "  $CODENAME [options]\n"
	printf "Options:\n"
	printf "  -c <config>\n"
	printf "    The config file to process.\n"
	printf "  -h\n"
	printf "    Display this help message and exit.\n"
	printf "  -n N\n"
	printf "    Sets the niceness to N (default 0).\n"
	printf "  -v\n"
	printf "    Print the version and exit.\n"
	printf "Examples:\n"
	printf "  $CODENAME -h\n"
	printf "  $CODENAME -n 5\n"
	printf "  $CODENAME -v\n"
	exit
}

# \brief Prints out the version and copyright and exits this program
function shearer_version
{
	printf "$NAME $VERSION $COPYRIGHT\n"
	exit
}

#------------------------------------------------------------------------------
# default configuration

CONFIG=".config"
DEBUG=false
NICE=0
TMP="/tmp"

#------------------------------------------------------------------------------
# config files

if [ -r /etc/$CODENAME.conf ]; then
	. /etc/$CODENAME.conf
fi
if [ -r ~/.$CODENAME.conf ]; then
	. ~/.$CODENAME.conf
fi

#------------------------------------------------------------------------------
# command line arguments

while getopts "c:hn:v" OPTION; do
	case "$OPTION" in
		"c") CONFIG="$OPTARG";;
		"h") shearer_help;;
		"n") NICE="$OPTARG";;
		"v") shearer_version;;
		*) shearer_help;;
	esac
done

#------------------------------------------------------------------------------
# prepare environment

trap shearer_exit SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM
TMP="$TMP/$CODENAME.$$"
mkdir -p "$TMP"
LOG="$TMP/log"
touch "$LOG"
renice $NICE $$ >>"$LOG" 2>>"$LOG"

#------------------------------------------------------------------------------
# begin execution

grep ^CONFIG "$CONFIG" > "$TMP/original"
make mrproper >/dev/null 2>/dev/null
make allmodconfig >/dev/null 2>/dev/null
grep ^CONFIG .config > "$TMP/allmodconfig"
grep "=m" .config > "$TMP/allmodules"

cp "$TMP/original" .config
IFS=$'\n'
for FULLCONFIG in `cat "$TMP/allmodconfig"`; do
	CONFIG=`echo $FULLCONFIG | sed -r -e 's/=.+//'`
	# do not change original options
	if grep -q $CONFIG "$TMP/original"; then
		#echo "Not changing $CONFIG"
		continue
	fi
	if echo "$FULLCONFIG" | grep -q "SUPPORT"; then
		echo "Setting $FULLCONFIG"
		echo "$FULLCONFIG" >> .config
		continue
	fi
	if echo "$FULLCONFIG" | grep -q "DRIVERS"; then
		echo "Setting $FULLCONFIG"
		echo "$FULLCONFIG" >> .config
		continue
	fi
done

make olddefconfig

for FULLCONFIG in `cat "$TMP/allmodules"`; do
	CONFIG=`echo $FULLCONFIG | sed -r -e 's/=.+//'`
	# do not change original options
	if grep -q $CONFIG "$TMP/original"; then
		#echo "Not changing $CONFIG"
		continue
	fi
	echo "Setting $FULLCONFIG"
	echo "$FULLCONFIG" >> .config
done
