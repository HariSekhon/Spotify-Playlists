#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-10-05 23:34:26 +0900 (Mon, 05 Oct 2026)
#
#  https///github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
NOT USED YET

It turns out there are a lot more tracks that I will need to consider the trade off in quality of loading them all
programmatically

Backports Decades playlists from their corresponding year playlist

Should be run after a clean backup as it uses local files for speed

If not run immediately after a backup, could result in duplicates due to using outdated local files as it checkes the
local decade playlists files for the track URIs before uploading them
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

num_args 0 "$@"

# from DevOps-Perl-tools which should be in \$PATH
check_bin uniq_order_preserved.pl

# all playlist paths are from the root of this repo
cd "$srcdir/.."

spotify_token

load_decade(){
    # pass name explicitly because I use funny irregular names for some decades
    local decade_playlist="spotify/$1"
    shift || :
    local years=()
    local year_playlists=()
    for year in "$@"; do
        if [ -f "Best of Year/Best of $year" ]; then
            years+=("$year")
            year_playlists+=("spotify/Best of Year/Best of $year")
        fi
    done
    timestamp "Loading Decade: $decade_playlist"
    timestamp "Uniq'ing years: ${years[*]}"
    timestamp "Filtering tracks not already in decade"
    uniq_order_preserved.pl "${year_playlists[@]}"|
    grep -Fvxhf "$decade_playlist" - |
    {
        timestamp "Adding tracks"
        echo
        wc -l
        #"$bash_tools/spotify/spotify_uri_to_name.sh"
    }
    echo
    echo
}


load_decade "The 2020s" {2020..2029}
load_decade "The 2010s" {2010..2019}
load_decade "The 2000s" {2000..2009}
load_decade "The 90s - The Decade of Dance, R&B 🇺🇸 & Brit Pop! 🇬🇧 ? 🎉" {1990..1991}
load_decade "The 80s - The Greatest Decade in Human History! 👩??? 👩? 👩? 😎 ? 🎉" {1980..1989}
load_decade "The 70s - The Decade of Disco & Classics! 💃 🕺 😎 ? 🎉" {1970..1979}
load_decade "The 60s" {1960..1969}
