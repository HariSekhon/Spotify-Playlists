Hari Sekhon - Spotify Playlists
===============================

[![Spotify Profile](https://img.shields.io/badge/Spotify%20Profile-HariSekhon-brightgreen?logo=spotify&style=social)](https://open.spotify.com/user/harisekhon)
[![Playlists](https://img.shields.io/badge/Playlists-220+-blue?logo=spotify)](https://open.spotify.com/user/harisekhon)
[![Tracks](https://img.shields.io/badge/Tracks-32,000+-blue?logo=spotify)](https://open.spotify.com/user/harisekhon)
[![Unique Tracks](https://img.shields.io/badge/Unique%20Tracks-16,000+-blue?logo=spotify)](https://open.spotify.com/user/harisekhon)

[![Travis CI](https://img.shields.io/travis/harisekhon/spotify-playlists/master?logo=travis&label=Travis%20CI)](https://travis-ci.org/HariSekhon/Spotify-Playlists)
[![CI Builds Overview](https://img.shields.io/badge/CI%20Builds-Overview%20Page-blue?logo=circleci)](https://bitbucket.org/harisekhon/devops-bash-tools/src/master/STATUS.md)
[![Repo on Azure DevOps](https://img.shields.io/badge/repo-Azure%20DevOps-0078D7?logo=azure%20devops)](https://dev.azure.com/harisekhon/GitHub/_git/Spotify-Playlists)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-2088FF?logo=github)](https://github.com/HariSekhon/Spotify-Playlists)
[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-FCA121?logo=gitlab)](https://gitlab.com/HariSekhon/Spotify-Playlists)
[![Repo on BitBucket](https://img.shields.io/badge/repo-BitBucket-0052CC?logo=bitbucket)](https://bitbucket.org/HariSekhon/Spotify-Playlists)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/HariSekhon/Spotify-Playlists?logo=github)](https://github.com/HariSekhon/Spotify-Playlists/commits/master)

[git.io/spotify-playlists](https://git.io/spotify-playlists)

An Epic collection of playlists built over a decade, using dozens of programs and scripts to track and manage to a high standard.

If you know a great track that isn't in one of these playlists, open [an issue](https://github.com/HariSekhon/Spotify-Playlists/issues) or message me on [LinkedIn](https://www.linkedin.com/in/harisekhon/) to add it!

Top level playlists are in human readable format `Artist - Track`.

Spotify URI format playlists are under the `spotify/` directory for backup/restore, analysis or copying to new playlists.

Hari Sekhon

[![My LinkedIn](https://img.shields.io/badge/LinkedIn%20Profile-HariSekhon-blue?logo=linkedin)](https://www.linkedin.com/in/harisekhon/)
[![Spotify Profile](https://img.shields.io/badge/Spotify%20Profile-HariSekhon-brightgreen?logo=spotify&style=social)](https://open.spotify.com/user/harisekhon)
###### (you're welcome to connect with me on LinkedIn)

#### Quick Guide

-  Genre mega mixes (eg. `Hip-Hop / R&B`, `Dance / Pop`, `Rock / Metal`, `Electronica`, `Classical`, `Motown / Soul`, `Classics`, `Club`, `Disco!` etc)
- `Best of <Genre>` / `<special name>` - shorter highest quality playlists (these are the ones you really want, listed below)
- `Artist` specific playlists
- Mixes in Time - `YYYY MM - <description>` date stamped mixes - stuff that was either hot at that time or that I discovered and listened to more at that time

#### Best of the Best

- `Upbeat & Sexual Pop` - the ultimate driving mega mix
- `Chill` - excellent chill tunes for work and life
- `Best R&B`
- `Best Pop`
- `Best Rock`
- `Best Motown / Funk / Boogie / Groove / Soul` - excellent tracks you wish you knew earlier, much of the best contemporary hip-hop tunes are "borrowed" from these Motown classics
- `Workout / Dance / Trance / DnB / Energy / Beats` - gym mega mix
- `Workout Hip-Hop (Aggressive)` - gym hardcore for guys pumping iron and hitting bags
- `Trance / Dance - Best of` - high energy gym mix, best vocal trance
- `Love Songs` - for your sweetie
- `Sensual` - for a nice evening in with the girlfriend
- `Songs About Sex` - for single guys with high testosterone in their prime, hip-hop based
- `Bad Boy Gets Down` - similar to above
- `Elite Hip-Hop with Attitude` - legendary hip-hop
- `Smooth Hip-Hop` - legendary hip-hop
- `Bounce to the Rhythm` - rhythm & vibes hip-hop, puts a bounce in your step
- `Light Fun Feel Good` - because sometimes you need to lighten up

#### The Tech Stuff

These playlists are downloaded and managed by scripts in the [DevOps Bash tools](https://github.com/harisekhon/bash-tools) and [Spotify tools](https://github.com/harisekhon/spotify-tools) repos which are available as submodules under the `bash-tools/` and `spotify-tools/` directories respectively.

Aside from Backup & Restore, keeping all playlists in both Spotify and human readable formats allows all sorts of handy tricks, eg:

- `grep`'ing your entire playlist catalog (which you can't do in Spotify's App)
- auto-removing duplicates from a given playlist (detected via URI and/or human readable name - different levels of duplicate detection)
- auto-removing tracks from todo playlists that are already in one of the core playlists so you don't have to check those tracks ever again (when combined with blacklist playlists this is a huge progressive efficiency gain)
- setting all of the tracks in your favourite playlists to `Liked Songs` without a zillion clicks in Spotify (useful to port over your `Starred` tracks)
- bulk-loading tracks from one or more playlists or even favourites from `Liked Songs`

[git.io/spotify-playlists](https://git.io/spotify-playlists)
