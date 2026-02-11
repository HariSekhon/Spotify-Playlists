#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-11-07 11:12:48 +0000 (Sat, 07 Nov 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Calculates the percentage of blacklist tracks in each Discover Backlog followed playlist and sorts descending

Uses the offline backup playlists for speed, so must be done after a full backup for accuracy
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

#export SPOTIFY_PRIVATE=1

#spotify_token

cd "$srcdir/.."

make pull >&2

discover_playlists="$("$bash_tools/bin/decomment.sh" "$srcdir/../private/discover_playlists.txt")"

if ! [ -f "$srcdir/../private/spotify/Blacklist" ]; then
    die "$srcdir/../private/spotify/Blacklist not found! Have you checked out the private repo?"
fi

# need GNU grep for -f ... Mac's grep is buggy
if is_mac; then
    grep(){
        command ggrep "$@"
    }
fi

# XXX: pre-load normalized blacklisted tracks for comparison
blacklisted_tracks="$("$srcdir/spotify-tools/normalize_tracknames.pl" "$srcdir/../private/Blacklist"*)"

#time \
while read -r playlist_line; do
    [ -z "$playlist_line" ] && continue
    # If there is a first token that matches a spotify ID then use it, otherwise assume the whole line is a playlist name
    playlist_id="${playlist_line%%[[:space:]]*}"
    # XXX: there is an assumption here that no playlist name will be 22 alphanumeric chars without spaces
    if is_spotify_playlist_id "$playlist_id"; then
        playlist_name="${playlist_line#*[[:space:]]}"
    else
        playlist_name="$playlist_line"
    fi
    # script only takes ~ 11 secs using local files so we don't need this progress, keep it concise
    #timestamp "Calculating % tracks blacklisted in playlist \"$playlist_name\""
    playlist_name="$("$bash_tools/spotify/spotify_playlist_to_filename.sh" <<< "$playlist_name")"
    playlist_filename="$bash_tools/../private/$playlist_name"
    if ! [ -f "$playlist_filename" ]; then
        die "ERROR: playlist file does not exist - was a full backup taken first? Not Found:  $playlist_filename"
    fi
    total_trackcount="$(wc -l "$playlist_filename" | awk '{print $1}')"
    # need a global count across all Blacklists, whereas grep -c will give per file
    # shellcheck disable=SC2126
    # must silence exit code with || : to prevent no matches in grep raising a pipefail and exiting the script prematurely
    blacklisted_trackcount="$(grep -Fx -f <("$srcdir/spotify-tools/normalize_tracknames.pl" "$playlist_filename") <<< "$blacklisted_tracks" | sort -u | wc -l | sed 's/[[:space:]]//g' || :)"
    percentage_blacklisted="$((100 * blacklisted_trackcount / total_trackcount))"
    printf '%3d%%\t%4d/%4d\t%s\n' "$percentage_blacklisted" "$blacklisted_trackcount" "$total_trackcount" "$playlist_line"
done <<< "$discover_playlists" |
sort -k1nr
