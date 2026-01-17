#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-10-31 10:23:36 +0000 (Sat, 31 Oct 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/bash-tools"

if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$srcdir/bash-tools/lib/spotify.sh"

threshold=3

# shellcheck disable=SC2034,SC2154
usage_description="
Lists artists with $threshold or more tracks in the Blacklist playlists and not tracks in core playlists

Useful to auto-delete tracks from Discover Backlog to get rid of overrated recommended artists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

SECONDS=0

export SPOTIFY_PRIVATE=1

spotify_token

cd "$srcdir"

filename="$srcdir/private/blacklisted_artists.txt"

trap_cmd 'echo ERROR'

tmp="$(mktemp)"

# TODO: dedupe this with tracks_already_in_playlists.sh, move to lib/spotify.sh or rework the logic to be simpler
core_playlists=()
while read -r playlist; do
    if [[ "$playlist" =~ Blacklist|Discover|TODO|Backlog ]]; then
        continue
    fi
    # auto-resolve each playlist's path to either ./ or ./private
    if [ -f "$srcdir/$playlist" ]; then
        core_playlists+=("$srcdir/$playlist")
    elif [ -f "$srcdir/private/$playlist" ]; then
        core_playlists+=("$srcdir/private/$playlist")
    else
        die "playlist not found: $playlist"
    fi
done < <(
    sed 's/^#.*//; /^[[:space:]]*$/d' "$srcdir/core_playlists.txt" |
    awk '{$1=""; print}' |
    "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh"
)

{
    #for blacklist in $(SPOTIFY_PRIVATE=1 "$bash_tools/spotify/spotify_playlists.sh" | cut -d' ' -f2- | sed 's/^[[:space:]]*//' | grep '^Blacklist'); do
    # quicker
    #for blacklist in Blacklist{,2,3}; do
    while read -r blacklist; do
        timestamp "Getting list of artists with >= $threshold tracks in $blacklist"
        "$bash_tools/spotify/spotify_playlist_artists.sh" "$blacklist" || exit 1
    done < <(
        grep -E '^Blacklist[[:digit:]]*$' "$srcdir/private/playlists.txt" | sort
    )
} |
sort |
uniq -c |
sort -k1nr |
while read -r count artist; do
    if [ "$count" -lt $threshold ]; then
        # causes a set -e exit triggering trap
        break
    fi
    # don't output any artist that is found in core playlists as they may have additional tracks worth having
    # don't strip song name as sometimes artists are suffixed by 'featuring ...', not always in the prefix artists comma separated - better to fail safe and exclude them
    grep -Fq "$artist" "${core_playlists[@]}" ||
    echo "$artist"
done |
sort -fu > "$tmp" || :
# || : to silence break exit code from loop above

timestamp "Deduping blacklisted artists"

tmp2="$(mktemp)"

# need to split the input and output files to avoid weird race conditions
cp -f "$tmp" "$tmp2"

timestamp "Removing any blacklist artists found in followed artists list"
while read -r artist; do
    if grep -Fxq "$artist" "$srcdir/artists_followed.txt"; then
        timestamp "Removing artist $artist"
        artist="${artist/\//\\/}"
        sed -i.bak "/^$artist/d" "$tmp2"
    fi
done < "$tmp"

timestamp "Removing any pre-existing blacklisted artists that have had tracks added to core playlists"
while read -r artist; do
    if grep -Fq "$artist" "${core_playlists[@]}"; then
        timestamp "removing artist $artist"
        artist="${artist/\//\\/}"
        sed -i.bak "/^$artist/d" "$tmp2"
    fi
done < "$tmp"

mv -f "$tmp2" "$filename"

untrap
timestamp "Finished generating artist blacklists in $SECONDS secs"

#cat "$filename"
