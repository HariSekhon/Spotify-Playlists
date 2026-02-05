#  vim:ts=4:sts=4:sw=4:noet
#
#  Author: Hari Sekhon
#  Date: 2020-07-07 00:38:27 +0100 (Tue, 07 Jul 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help improve or steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

override BASH_TOOLS := $(shell test -d "$(PWD)/bash-tools" && echo "$(PWD)/../bash-tools" || echo "$(PWD)/bash-tools")

$(info Using bash-tools: $(BASH_TOOLS))

ifneq ("$(wildcard $(BASH_TOOLS)/Makefile.in)", "")
	include $(BASH_TOOLS)/Makefile.in
endif

REPO := HariSekhon/Spotify-Playlists

# looks like git printenv are still called even for an overridden target, even with an overridden dependency
.PHONY: default
default:
	@$(MAKE) updates # dedupe # push

.PHONY: build
build: init
	@echo =================
	@echo Spotify Playlists
	@echo =================
	@$(MAKE) git-summary
	@echo

	@# doesn't exit Make anyway, only line, and don't wanna use oneshell
	@#if [ -z "$(CPANM)" ]; then make; exit $$?; fi
	cd "$(BASH_TOOLS)" && "$(MAKE)"
	cd spotify-tools && "$(MAKE)"

	@echo
	@echo "BUILD SUCCESSFUL (Spotify Playlists)"
	@echo
	@echo

.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: lazy-init
lazy-init:
	@if ! [ -d bash-tools ]; then \
		$(MAKE) init build; \
	fi

.PHONY: backup
backup: lazy-init
	@# don't pre-load one long-lived token because it times out after 1 hour before all playlists are downloaded now
	@# allow scripts to generate new tokens
	#export SPOTIFY_ACCESS_TOKEN="$$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify/spotify_api_token.sh)"
	@$(BASH_TOOLS)/checks/check_internet.sh && \
	SECONDS=0 && \
	./backup.sh && \
	echo && \
	echo && \
	./backup_private.sh && \
	echo && \
	./update_playlist_names.sh && \
	echo "Public + Private backups completed in $$SECONDS seconds"

.PHONY: backups
backups: backup
	@:

# Remove stale id files for playlists that were renamed
.PHONY: clean
clean:
	for id in id/*; do \
		playlist="$${id#id/}"; \
		playlist="$${playlist%.id.txt}"; \
		if ! [ -f "$$playlist" ]; then \
			echo rm -v "$$id"; \
		fi; \
	done

.PHONY: blacklists
blacklists:
	./backup_private.sh `ls private/Blacklist* | grep -v '\.description$$' | sed 's|private/||'`

.PHONY: commit
commit: lazy-init
	./commit.sh

# need ordering so not putting as dependencies to avoid concurrency bug using eg. make -j 2
.PHONY: updates
updates: # backup commit
	@# check internet is up before erroring out as I often launch this immediately after connecting to a wifi network
	@# only to come back and find it has errored out before the network is fully up
	@# waits for internet to become fully available checking IP Routing, DNS and Connectivity
	$(MAKE) backup
	@echo
	@echo
	@# needs redesign now there are two Pop Mega-Mix parent playlists
	@#$(MAKE) aggregate
	@echo
	@echo
	./like_all_tracks_in_playlists.sh
	@echo
	$(MAKE) commit

.PHONY: update
update: updates
	@:

.PHONY: artists
artists:
	"$(BASH_TOOLS)/spotify/spotify_backup_artists_followed.sh"

.PHONY: playlists
playlists:
	SPOTIFY_PRIVATE=1 \
	SPOTIFY_PUBLIC_ONLY=1 \
	"$(BASH_TOOLS)/spotify/spotify_backup_playlists_list.sh"
	@echo
	cd private && \
	SPOTIFY_PRIVATE=1 \
	SPOTIFY_PUBLIC_ONLY= \
	SPOTIFY_PRIVATE_ONLY=1 \
	"$(BASH_TOOLS)/spotify/spotify_backup_playlists_list.sh"

.PHONY: discover
discover:
	./discover_backlog_load.sh
	$(MAKE) dedupe

.PHONY: dedupe
dedupe:
	./discover_backlog_dedupe.sh
	./spotify_delete_duplicates_in_playlist.sh "My Shazam Tracks"

.PHONY: aggregate
aggregate:
	./aggregate_playlists.sh

.PHONY: pull
pull:
	git pull --no-edit && \
	pushd private/ && \
	git pull --no-edit

.PHONY: pull2
pull2: pullstash
	@:

.PHONY: pullstash
pullstash:
	git stash && \
	git pull --no-edit && \
	pushd private/ && \
	git stash && \
	git pull --no-edit && \
	git stash pop; \
	popd && \
	git stash pop || :

.PHONY: pullreset
pullreset:
	git reset --hard && \
	git pull --no-edit && \
	pushd private/ && \
	git reset --hard && \
	git pull --no-edit

.PHONY: push
push: pull
	bash-tools/git/git_review_push.sh && \
	cd private/ && \
	../bash-tools/git/git_review_push.sh

.PHONY: test
test: validate
	@:

.PHONY: validate
validate:
	./validate.sh

.PHONY:
wc:
	./wc.sh
