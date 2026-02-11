#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-25 23:37:23 +0100 (Fri, 25 Sep 2020)
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

discover_playlists="$(sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/private/discover_playlists.txt")"
num_discover_playlists="$(wc -l <<< "$discover_playlists" | sed 's/[[:space:]]*//g')"

# shellcheck disable=SC2034,SC2154
usage_description="
Loads tracks to the Discover Backlog playlist from the following followed playlists, then removes duplicates and tracks already in main playlists

This has grown to be massive, loading several thousand tracks, then running various levels of dedupe and matching against itself, all core vetted playlists and blacklist. Now takes around 27 minutes to run!!

$num_discover_playlists Followed Playlists:

$discover_playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

duplicate_playlists="$(sort -u <<< "$discover_playlists" | uniq -d)"

if [ -n "$duplicate_playlists" ]; then
    die "Duplicate playlists detected - clean up the file: $srcdir/../private/discover_playlists.txt:

$duplicate_playlists
"
fi

export SPOTIFY_PRIVATE=1

spotify_token

# ============================================================================ #
#                               Pre-flight checks
# ============================================================================ #

cd "$srcdir/.."

make pullstash

# check there are no duplicate playlists above slowing us down before we start as this is already a mega load
if sort <<< "$discover_playlists" | uniq -d | grep .; then
    echo "Duplicate playlists detected in code!"
    exit 1
fi

if ! [ -d private ]; then
    echo "private/ subdirectory not found for playlist name pre-flight check"
    exit 1
fi

"$srcdir/backup_playlists_lists.sh"
echo >&2

# ensure none of the playlists have been renamed
timestamp "Checking all discover playlists are present"
while read -r playlist_line; do
    if grep -Fxq "$playlist_line" private/playlists.txt private/spotify/playlists.txt private/playlists_followed.txt; then
        continue
    fi
    playlist_id="${playlist_line%%[[:space:]]*}"
    if is_spotify_playlist_id "$playlist_id"; then
        if grep -q "^${playlist_id}[[:space:]]" private/spotify/playlists.txt private/playlists_followed.txt; then
            continue
        fi
    fi
    die "Playlist not found:  $playlist_line"
done <<< "$discover_playlists"

# ============================================================================ #

# detect followed playlists so we can convert their playlist names to IDs are well
export SPOTIFY_PLAYLISTS_FOLLOWED=1

"$srcdir/discover_backlog_dedupe.sh"
echo

discover_backlog_playlist_id="$("$bash_tools/spotify/spotify_playlist_name_to_id.sh" "Discover Backlog")"

"$srcdir/discover_backlog_load_user.sh" mayatriforce
"$srcdir/discover_backlog_load_user.sh" 1163908670  # Gemma
echo

#timestamp "Loading tracks from followed artists"
#"$srcdir/bash-tools/spotify/spotify_artists_followed_uri.sh" |
#while read -r artist_uri; do
#    "$srcdir/bash-tools/spotify/spotify_artist_tracks.sh" "$artist_uri" |
#    "$bash_tools/spotify/spotify_add_to_playlist.sh" "$discover_backlog_playlist_id"
#done

# 10m30s
time \
while read -r playlist_line; do
    [ -z "$playlist_line" ] && continue
    echo
    # If there is a first token that matches a spotify ID then use it, otherwise assume the whole line is a playlist name
    playlist_id="${playlist_line%%[[:space:]]*}"
    # XXX: there is an assumption here that no playlist name will be 22 alphanumeric chars without spaces
    if [[ "$playlist_id" =~ ^[[:alnum:]]{22}$ ]]; then
        playlist_name="${playlist_line#*[[:space:]]}"
        timestamp "Loading tracks from playlist id $playlist_id ( $playlist_name ) to Discover Backlog"
        "$bash_tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_id"
    else
        playlist_name="$playlist_line"
        timestamp "Loading tracks from playlist \"$playlist_name\" to Discover Backlog"
        "$bash_tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_name"
    fi |
    "$bash_tools/spotify/spotify_add_to_playlist.sh" "$discover_backlog_playlist_id"
done <<< "$discover_playlists"

echo
# 18m
exec "$srcdir/discover_backlog_dedupe.sh"
