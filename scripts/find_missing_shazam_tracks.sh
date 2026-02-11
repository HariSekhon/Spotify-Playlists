#!/usr/bin/env bash
#  vim:ts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2012-06-04 18:11:42 -0700 (Mon, 04 Jun 2012)
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

cd "$srcdir/.."

# 1. Used iPhone explorer to copy the whole Shazam dir to Mac
# 2. grep -R the dir for a known song nme to find the location of the data, was in a sqlite DB
# 3. figured out DB internal to get a basic join of Artist - Track selects with | as the separator
# 4. Pipe through shell to munge and enjoy! :)
# 5. Took back using this select to txt file Shazam-dump-$(date +%F).txt
# 6. WARNING: for some reason this doesn't seem to have the very latest tags in it
# 7. Also there is something wrong with this list, Adele - Church for Thugs???

#sqlite3 $HOME/Downloads/Shazam-rip-from-phone/Documents/ShazamDataModel.sqlite <<< "select a.zname, b.zname from ZSHARTISTMO a, ZSHTAGRESULTMO b where a.Z_PK = b.Z_PK;" | sed 's/ [Ff]eat[^-]*|/|/;s/|/.*-.*/' | sort -u |
# Turns out the original query was wrong, that's why Artist - Tracks were getting muddled
#sqlite3 $HOME/Downloads/Shazam-rip-from-phone/Documents/ShazamDataModel.sqlite <<< "select a.zname, b.zname from ZSHARTISTMO a, ZSHTAGRESULTMO b where a.ZTAGRESULT = b.Z_PK;" | sed 's/ [Ff]eat[^-]*|/|/;s/|/.*-.*/' | sort -u |
#./dump_shazam_tracks.sh
shazam_dump="$(find . -iname 'Shazam-dump-*.txt' | tail -n 1)"
echo "using last $shazam_dump" >&2
sed 's/ [Ff]eat[^-]*|/|/;s/|/.*-.*/;s/^The //' < "$shazam_dump" |
sort -fu |
while read -r track; do
    # TODO: needs updating to modern playlist names
    grep -qi "$track" dance kiss rock classics chill classical love jazz disco Shazam-ignore.txt || sed 's/\.\*/ /g' <<< "$track"
done
