#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-18 09:21:12 +0100 (Sat, 18 Jul 2020)
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

# shellcheck disable=SC2034
usage_description="
Finds playlist files that are not referenced in the list of updated playlists in playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

cd "$srcdir"

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

help_usage "$@"

git ls-files |
grep -v -e spotify/ \
        -e '^\.' \
        -e '\.sh' \
        -e '\.txt' \
        -e 'bash-tools' \
        -e 'spotify-tools' \
        -e Makefile \
        -e README.md \
        -e old/ \
        -e other/ |
while read -r filename; do
    # convert unicode replacement back to original slash
    filename="${filename//∕//}"
    filename="${filename#\"}"
    filename="${filename%\"}"
    filename="${filename//\\/}"
    if ! grep -Fqx "$filename" playlists.txt; then
        echo "$filename"
    fi
done
