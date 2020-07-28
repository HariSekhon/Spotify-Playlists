Hari Sekhon - Spotify Playlists
===============================

##### 220+ public Spotify playlists with 30,000+ tracks (15,000+ unique tracks)

An Epic collection that has taken me a decade to build and dozens of programs and scripts to manage to a high standard.

If you know a great track that isn't in one of these playlists, please send it to me! ([My LinkedIn](https://www.linkedin.com/in/harisekhon))

Top level playlists are in human readable format `Artist - Track`.

Spotify URI format playlists are under the `spotify/` directory for backup/restore or copying to new playlists.

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

Keeping all playlists in both Spotify and human readable formats allows all sorts of handy tricks, eg:
- `grep`'ing your entire playlist catalog (which you can't do in Spotify's App)
- auto-removing duplicates from a given playlist (detected via URI and/or human readable name - different levels of duplicate detection)
- auto-removing tracks from todo playlists that are already in one of the core playlists so you don't have to check those tracks ever again (when combined with blacklist playlists this is a huge progressive efficiency gain)
- setting all of the tracks in your favourite playlists to `Liked Songs` without a zillion clicks in Spotify
- bulk-loading tracks from one or more playlists or even favourites from `Liked Songs`
