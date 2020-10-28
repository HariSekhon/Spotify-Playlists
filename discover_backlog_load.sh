#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-25 23:37:23 +0100 (Fri, 25 Sep 2020)
#
#  https://github.com/harisekhon/spotify-playlists
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

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/spotify.sh"

followed_playlists="
Discover Weekly
New Music Friday
Best New Music
Favourite New Releases
The motherfucking future
mint
just hits
Night Rider
Today's Top Hits
Viral Hits
Hot Hits UK
Top Pop
The Pop List
UK Top 50
United Kingdom Top 50
Billboard Hot 100
Dazed's The Only Tracks You Need To Hear
The Drop
Spotify's Most Played All-Time
Top Tracks - All Time
Top Tracks - Last Month
Top Tracks - Last Six Months
billboard Number Ones
<3 XXXO <3
Signed XOXO
RapCaviar
wRap Caveat
Who We Be
Most Necessary
Jazz Rap
Happy Beats
Massive Dance Hits
The Dance List
The Dance Tent
Dance Hits
Dance Party
House Supreme
UK House Music
Housewerk
Altar
Bassline Bangers
Warehouse Party
Trance Energy
Soak Up the Sun
Are & Be
You & Me
B.A.E.
The Sweet Suite
Chilled R&B
R&B 2020
Tropical House
Poolside Disco
Soul Lounge
Funk Outta Here
Workout Twerkout
Power Hour
Power Workout
Hype
Brain Food
4AM Chillout
License To Chill
Chill Tracks
Dance Classics
Massive Dance Classics
Ibiza Classics
Gold School
I Love My '00s R&B
'90s Baby Makers
All Out 00s
All Out 90s
All Out 80s
All Out 70s
80s Dance Hits
Rave Classics
Rock Classics
Rock Ballads
Rock Me UP!
It's ALT Good!
Nu Metal Generation
Soul Revived
This Is: Skepta
This Is Rihanna
This is Roxette
The Most Romantic Songs in the World
"

# shellcheck disable=SC2034,SC2154
usage_description="
Loads Discover Backlog tracks from the following playlists, then removes duplicates and tracks already in main playlists

Followed Playlists:

$followed_playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

# check there are no duplicate playlists above slowing us down before we start as this is already a mega load
if sort <<< "$followed_playlists" | uniq -d | grep .; then
    echo "Duplicate playlists detected in code!"
    exit 1
fi

export SPOTIFY_PRIVATE=1

# detect followed playlists so we can convert their playlist names to IDs are well
export SPOTIFY_PLAYLISTS_FOLLOWED=1

spotify_token

time \
while read -r playlist; do
    [ -z "$playlist" ] && continue
    echo
    timestamp "Loading tracks from playlist \"$playlist\" to Discover Backlog"
    "$srcdir/bash-tools/spotify_playlist_tracks_uri.sh" "$playlist" |
    "$srcdir/bash-tools/spotify_add_to_playlist.sh" "Discover Backlog"
done <<< "$followed_playlists"

echo
time {
    time {
        # this often gets an internal 500 error after 1100 track deletions (11 batched calls), seems like a bug in Spotify's API, so run more than once to work around the problem
        for _ in 1 2 3; do
            "$srcdir/bash-tools/spotify_delete_any_duplicates_in_playlist.sh" "Discover Backlog" || continue
            break
        done
    }

    echo
    time {
        "$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog" ||
        "$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog"
    }
}
