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
    echo "=== SVN UNLOCK OF PARAGRAPH '${ARG1}'"
    if test ! -d "${ARG1}"; then
      echo "!!! '${ARG1}' is not a directory. Stopping."
      exit 1
    fi


    #
    # Unlock files
    #
    xmllist=$(find ${ARG1} -maxdepth 1 -iname "*.xml" -and -not -name index.xml)
    svn unlock --force ${(f)xmllist}

    echo "*** DONE. SVN UNLOCK OF PARAGRAPH '${ARG1}'"
} |& println
