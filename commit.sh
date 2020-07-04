#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-03 17:14:30 +0100 (Fri, 03 Jul 2020)
#
#  https://github.com/harisekhon/playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC2034
usage_description="
Iterates over all playlists, showing diffs and then committing each in turn

First shows only the net additions / removals in standard Spotify URIs for a playlist
(to avoid variations in Spotify artist/track/tags from creating false positives)

If there are no net removals then auto-commits the playlist

Otherwise shows the full human readable playlist diff and spotify URI diff underneath

If satisfactory, hitting enter at the end of the playlist diff will commit both
the Spotify URI and human readable playlist simultaneously

This allows quick decisions such as if there are no net differences or only additions, it's
obviously safe to just scan the human diff and commit quickly

Requires DevOps-Perl-tools to be in \$PATH for diffnet.pl
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<playlist>]"

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC1090
#. "$srcdir/bash-tools/.bash.d/git.sh"

help_usage "$@"

cd "$srcdir"

commit_playlist(){
    playlist="$1"
    if ! [ -f "$playlist" ] ||
       ! [ -f "spotify/$playlist" ]; then
        return
    fi
    if git status -s "$playlist" "spotify/$playlist" | grep -q '^[?A]'; then
        git add "$playlist" "spotify/$playlist"
        git ci -m "added $playlist spotify/$playlist" "$playlist" "spotify/$playlist"
        return
    fi
    echo "Net Removals from playlist '$playlist' (could be replaced with different track version):"
    echo
    net_removals="$(find_net_removals "$playlist")"
    if [ -z "$net_removals" ]; then
        echo "Auto-committing playlist '$playlist' as no net removals"
        echo
        git add "$playlist" "spotify/$playlist"
        git ci -m "updated $playlist spotify/$playlist" "$playlist" "spotify/$playlist"
        echo
        return
    fi
    echo "$net_removals"
    echo
    read -r -p "Hit enter to see full human and spotify diffs or Control-C to exit"
    echo
    git diff "$playlist" "spotify/$playlist"
    echo
    read -r -p "Hit enter to commit playlist '$playlist' or Control-C to exit"
    echo
    git add "$playlist" "spotify/$playlist"
    git ci -m "updated $playlist spotify/$playlist"
}

find_net_removals(){
    local playlist="$1"
    git diff "spotify/$playlist" |
    diffnet.pl |
    grep ^- |
    sed 's/^-//' |
    while read -r uri; do
        if grep -Fxq "$uri" "spotify/$playlist"; then
            #echo "skipping duplicate URI '$uri' which is present in spotify/$playlist"
            continue
        fi
        track="$("$srcdir/bash-tools/spotify_track_uri_to_name.sh" <<< "$uri")"
        if grep -Fxq "$track" "$playlist"; then
            #echo "skipping track '$track' which is found in $playlist (must have been replaced with a different URI)"
            continue
        fi
        printf '%s\t%s\n' "$uri" "$track"
    done
}

if [ $# -gt 0 ]; then
    for playlist in "$@"; do
        commit_playlist "$playlist"
    done
else
    for playlist in $(git status --porcelain |
                      grep '^.M' |
                      awk '{print $2}' |
                      sed 's,spotify/,,' |
                      sort -u); do
        commit_playlist "$playlist"
    done
fi
