#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

# Avoid locale errors
LC_CTYPE=

echo "=== SVN UPDATE on '${ARG1}'"
echo "--- Logging send to '${ARG2}'"


echo "--- Trying to fix svn issues on ${ARG1}"


svn update --accept mine-conflict "$ARG1"
