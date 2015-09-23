#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

echo "=== SVN STATUS on '${ARG1}'"

if [[ ! -e "${ARG1}" ]]; then
    echo "*** Error: Path '${ARG1}' does not exist"
    exit 1
fi

svn status "$ARG1"
