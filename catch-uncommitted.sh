#!/bin/sh
set -e

catch_no_git=0
extra_args=''

while [ $# -gt 0 ]; do
	key=$1
	shift
	case $key in
		--catch-no-git)
			catch_no_git=1
		;;
		--skip-node-versionbot-changes)
			extra_args="${extra_args} "":(exclude)package.json"" "":(exclude)package-lock.json"" "":(exclude)CHANGELOG.md"""
		;;
	esac
done

echo

if [ $catch_no_git -eq 1 ] && !(hash git 2> /dev/null); then
	echo "git not found, not running catch-uncommitted check"
	exit 0
elif ! git diff HEAD --exit-code -- . $extra_args ; then
	echo '** Uncommitted changes found (^^^ diff above ^^^) - FAIL **'
	exit 1
elif test -n "$(git ls-files --exclude-standard --others | tee /dev/tty)" ; then
	echo '** Untracked uncommitted files found (^^^ listed above ^^^) - FAIL **'
	exit 2
else
	echo 'No unexpected changes, all good.'
fi
