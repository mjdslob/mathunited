#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script commits the changes in the paragraph communicated through ARG1
#

# Avoid locale errors
LC_CTYPE=

# Define println function that writes to output. If gawk is present the lines
# are prependend with a time stamp
if ! type gawk > /dev/null; then
function println() {
    cat
}
else
function println() {
    gawk '{ print strftime("%Y-%m-%d|%H:%M:%S|"), $0; fflush(); }'
}
fi

# Capture all output
{
    echo "=== SVN ADD AND COMMIT OF IMAGE '${ARG1}'."
    if test ! -f "${ARG1}"; then
      echo "!!! '${ARG1}' is not a file. Skipping."
      exit 1
    fi

    echo "--- Running 'svn add' on image ${ARG1}"
    svn add --parents --force ${ARG1}

    echo "--- Running 'svn commit' on path ${ARG1}"
    svn commit ${ARG1} -m "Image added."

    echo "*** DONE. SVN ADD AND COMMIT OF IMAGE '${ARG1}'."
} |& println
