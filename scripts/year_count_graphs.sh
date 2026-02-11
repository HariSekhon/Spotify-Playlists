#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-02-11 03:12:58 -0300 (Wed, 11 Feb 2026)
#
#  https///github.com/HariSekhon/Spotify-Playlists
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

default_dir="$srcdir/../Best of Year"

# shellcheck disable=SC2034,SC2154
usage_description="
Generates graphs of unique tracks per year from playlists:

    $default_dir/Best of YYYY

Each file contains lines:

    Artist - Track

Uses normalize_tracknames.pl to normalize titles before dedupe

Outputs:

    tracks_per_year.dat
    tracks_per_year.png        (gnuplot)
    tracks_per_year.mmd        (MermaidJS)

Requires:

    - gnuplot
    - mermaidjs cli
    - normalize_tracknames.pl from HariSekhonSpotify-tools repos
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<Best_of_Year_directory>]"

help_usage "$@"

dir="${1:-$default_dir}"

check_bin gnuplot
check_bin mmdc

outfile="tracks_per_year.dat"
gnuplot_code="tracks_per_year.gnuplot"
gnuplot_png="tracks_per_year.png"
mermaid_code="tracks_per_year.mmd"
mermaid_svg="tracks_per_year.svg"

if [ ! -d "$dir" ]; then
    die "Directory not found: $dir"
fi

tmpfile="$(mktemp)"
trap_cmd "rm -f \"$tmpfile\""

timestamp "Generating per-year unique track counts..."

for file in "$dir"/*; do
    [ -f "$file" ] || continue

    year="$(basename "$file" | grep -o '[0-9]\{4\}' || true)"

    [ -n "$year" ] || continue

    normalize_tracknames.pl < "$file" \
        | sort -u \
        | wc -l \
        | awk -v y="$year" '{print y, $1}' \
        >> "$tmpfile"
done

sort -n "$tmpfile" > "$outfile"

timestamp "Data written to: $outfile"

timestamp "Generating GNUplot Graph"

cat > "$gnuplot_code" <<EOF
set terminal pngcairo size 1280,720 enhanced font 'Arial,14' \
    background rgb "#1e1e1e"

set output "$gnuplot_png"

set datafile separator ' '
set boxwidth 0.6 relative
set style fill solid border -1

# Dark theme styling
set border lc rgb "#aaaaaa"
set tics textcolor rgb "#dddddd"
set xlabel textcolor rgb "#dddddd"
set ylabel textcolor rgb "#dddddd"
set title textcolor rgb "#ffffff"

set grid lc rgb "#444444"

set title "Unique Tracks Per Year"
set xlabel "Year"
set ylabel "Unique Tracks"

set xtics rotate by -75

plot "$outfile" using 2:xtic(1) with boxes lc rgb "#4ea1ff" notitle
EOF

timestamp "GNUplot code written to: $gnuplot_code"

gnuplot "$gnuplot_code"

timestamp "GNUplot graph written to: $gnuplot_png"

timestamp "Opening graph image: $gnuplot_png"

"$bash_tools/media/imageopen.sh" "$gnuplot_png"

# MermaidJS x-axis is ugly, don't use it
exit 0

#echo >&2
#
#timestamp "Generating MermaidJS Graph"
#
#x_labels=$(awk '{printf "\"%s\",",$1}' "$outfile" | sed 's/,$//')
#values=$(awk '{printf "%s,",$2}' "$outfile" | sed 's/,$//')
#
#cat > "$mermaid_code" <<EOF
#---
#config:
#  theme: dark
#  xyChart:
#    xAxis:
#      labelRotation: -45
#---
#xychart-beta
#    title "Unique Tracks Per Year"
#    x-axis [$x_labels]
#    y-axis "Tracks"
#    bar [$values]
#EOF
#
#timestamp "MermaidJS code written to: $mermaid_code"
#
#mmdc -i "$mermaid_code" -o "$mermaid_svg" -t dark --quiet # -b transparent
#
#timestamp "MermaidJS graph written to: $mermaid_svg"
#
#timestamp "Opening image: $mermaid_svg"
#
#"$bash_tools/media/imageopen.sh" "$mermaid_svg"
#
#timestamp "Done"
