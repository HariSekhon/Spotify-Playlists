#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-02-10 01:44:12 -0300 (Tue, 10 Feb 2026)
#
#  https///github.com/HariSekhon/Spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback
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
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Validates the path mappings file
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<path_mappings_file>]"

help_usage "$@"

file="${1:-.path_mappings.txt}"

cd "$srcdir/.."

[ -f "$file" ] || {
    die "ERROR: mapping file not found: $file"
}

timestamp "Validating: $file"
echo

declare -a seen_regex
lineno=0
errors=0

while IFS= read -r line; do
    lineno=$((lineno + 1))

    raw="$line"
    line="${line%%#*}"
    line="$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' <<< "$line")"

    [ -z "$line" ] && continue

    # Split TAB or 2+ spaces
    if [[ "$line" == *$'\t'* ]]; then
        dir="${line%%$'\t'*}"
        regex="${line#*$'\t'}"
    else
        dir="$(sed -E 's/[[:space:]]{2,}.*//' <<< "$line")"
        regex="$(sed -E 's/^.*[[:space:]]{2,}//' <<< "$line")"
    fi

    if [ -z "$regex" ] || [ "$dir" = "$regex" ]; then
        echo "Line $lineno: ERROR missing separator" >&2
        echo "  $raw" >&2
        echo
        errors=$((errors + 1))
        continue
    fi

    # Validate regex
    if ! grep -E "$regex" /dev/null >/dev/null 2>&1; then
        returncode=$?
        if [ "$returncode" -eq 2 ]; then
            echo "ERROR: Line $lineno: invalid regex" >&2
            echo "  $regex" >&2
            echo
            errors=$((errors + 1))
        fi
    fi
    # Duplicate detection
    for prev in "${seen_regex[@]:-}"; do
        if [ "$prev" = "$regex" ]; then
            warn "Line $lineno: duplicate regex (rule unreachable)"
            echo "  $regex" >&2
            echo
        fi
    done

    seen_regex+=("$regex")

done < "$file"

if [ "$errors" -eq 0 ]; then
    timestamp "Validation OK"
else
    timestamp "Validation FAILED ($errors errors)"
    exit 1
fi
