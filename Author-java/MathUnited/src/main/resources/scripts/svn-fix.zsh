#!/bin/zsh
#
# Part of Math4All authoring tool.
#
# This script checks the subversion status
#

# Avoid locale errors
LC_CTYPE=

# Check if gawk exist
if ! type gawk > /dev/null; then
function println() {
    /usr/bin/tee -a "${ARG2}"
}
else
function println() {
    gawk '{ print strftime("%Y-%m-%d|%H:%M:%S|"), $0; fflush(); }' | /usr/bin/tee -a "${ARG2}"
}
fi

# Capture all output
{
    echo "=== SVN FIX on '${ARG1}'"
    echo "--- Logging send to '${ARG2}'"

    if [[ ! -e "${ARG1}" ]]; then
        echo "*** Error: Path '${ARG1}' does not exist"
        exit 1
    fi

    cd ${ARG1}

    # Cleanup svn tree
    echo "--- Running svn cleanup"
    svn cleanup

    # Remove empty directories
    echo "--- Removing completely empty directories (no content, no .svn)"
    find . -type d -empty -not -iwholename "*.svn*" -print -delete

    # Find content directories by looking for index.xml
    indexes=$(/bin/ls -1 **/index.xml)

    # Remove index.xml's from repo
    echo "--- Removing index.xml's from repo"
    svn rm --keep-local ${(f)indexes}
    svn commit . -m "(svn-fix) Removed index.xml's from repo"

    dirs=$(for index in ${(f)indexes}; do echo ${index:h}; done)
    for d in ${(f)dirs}; do ( # in subshell
        cd $d
        echo "--- Trying to fix ${ARG1}/${d}"
        comp=$d:h
        subcomp=$d:t
        # Add images
        for extradir in images/highres geogebra dox; do
          if test -d $extradir; then
            echo "... Media in $d/$extradir"
            list=$(find ${extradir} -maxdepth 1 -type f -not -name ".*")
            if test ! -z "$list"; then
              svn add --parents --force ${(f)list}
              svn commit -m "(svn-fix) Added unversioned media in $d/$extradir"
            fi
          fi
        done
        # Add xml files
        echo "... XML in subdirs of $d"
        list=$(find . -mindepth 2 -maxdepth 2 -iname "*.xml" -and -not -name index.xml)
        if test ! -z "$list"; then
          svn add --parents --force ${(f)list}
          svn commit . -m "(svn-fix) Added unversioned files in $d"
        fi
    )
    done

    # Run an update and accept conflicts
    echo "--- Pull in changes from repo"
    svn update --accept mine-conflict "$ARG1"

    # Put back to the server
    echo "--- Put back resolved conflictes to repo"
    svn commit "$ARG1" -m "(svn-fix) Overruled conflicts"

    echo "*** DONE. SVN FIX on '${ARG1}'"

} |& println
