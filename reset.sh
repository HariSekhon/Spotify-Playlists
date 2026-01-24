#!/usr/bin/env bash

set -euo pipefail

# playlists that have substantial changes that need review, for now just revert and deal with them later
playlists_to_reset="
LL Cool J
Fabulous
Christmas
"

while read -r playlist; do
    [ -z "$playlist" ] && continue
    echo "Resetting playlist: $playlist"
    git checkout "$playlist" "spotify/$playlist"
done <<< "$playlists_to_reset"

echo "Deleting temporary playlist pollution:"
rm -vf Love\ I\ * spotify/Love\ I\ *
