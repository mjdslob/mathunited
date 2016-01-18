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
    echo "=== XML FIXUP OF PARAGRAPH '${ARG1}'"
    if test ! -d "${ARG1}"; then
      echo "!!! '${ARG1}' is not a directory. Stopping."
      exit 1
    fi

    echo "--- Fixing xsi:noNamespaceSchemaLocation on  all XML in ${ARG1}"
    # Process top level XML files except for index.xml
    for f in $(find ${ARG1} -maxdepth 1 -iname "*.xml" -and -not -name index.xml); do
      # Only process files with wrong xsi tag
      if grep -q xsi:nonamespaceschemalocation ${f}; then
        echo "--- ... ${f:t}"
        # Run inplace sed and delete backup only if succesful
        sed -i.bak -e 's/xsi:nonamespaceschemalocation/xsi:noNamespaceSchemaLocation/g' $f && rm ${f}.bak
      fi
    done


    echo "*** DONE. XML FIXUP OF PARAGRAPH '${ARG1}'"
} |& println
