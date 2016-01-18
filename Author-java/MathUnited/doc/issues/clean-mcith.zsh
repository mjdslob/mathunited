#!/bin/zsh

for highres in $(find . -name highres); do
	(cd $highres
	echo "--- Removing thumbnails from $highres"
	parent=$(cd .. && basename $(pwd))
	if test "${parent}" = images; then
		if test -d mcith; then
			echo " -- Found thumbail dir"
			echo "  - Restoring clean state"
			rm -rf mcith
			echo "  - Getting repo version"
			svn update
			echo "  - Removing from repo"
			svn rm mcith
		fi
		echo " -- Ignoring thumbnails in future"
		svn propset svn:ignore mcith .
		echo " -- Committing $highres"
		svn commit . -m "Removed thumbnails from $highres"
	fi)
done

