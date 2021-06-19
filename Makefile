#  vim:ts=4:sts=4:sw=4:noet
#
#  Author: Hari Sekhon
#  Date: 2020-07-07 00:38:27 +0100 (Tue, 07 Jul 2020)
#
#  https://github.com/harisekhon/spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help improve or steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

ifneq ("$(wildcard bash-tools/Makefile.in)", "")
	include bash-tools/Makefile.in
endif

REPO := HariSekhon/Spotify-Playlists

# looks like git printenv are still called even for an overridden target, even with an overridden dependency
.PHONY: default
default:
	@$(MAKE) updates dedupe # push

.PHONY: build
build: init
	@echo =================
	@echo Spotify Playlists
	@echo =================
	@$(MAKE) git-summary
	@echo

	@# doesn't exit Make anyway, only line, and don't wanna use oneshell
	@#if [ -z "$(CPANM)" ]; then make; exit $$?; fi
	cd bash-tools && $(MAKE)
	cd spotify-tools && $(MAKE)

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
	@SECONDS=0 && \
	export SPOTIFY_ACCESS_TOKEN="$$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify_api_token.sh)" && \
	./backup.sh && \
	echo && \
	echo && \
	./backup_private.sh && \
	echo && \
	echo "Public + Private backups completed in $$SECONDS seconds"

.PHONY: backups
backups: backup
	@:

.PHONY: commit
commit: lazy-init
	./commit.sh

# need ordering so not putting as dependencies to avoid concurrency bug using eg. make -j 2
.PHONY: updates
updates: # backup commit
	$(MAKE) backup
	@echo
	@echo
	$(MAKE) aggregate
	@echo
	@echo
	$(MAKE) commit

.PHONY: update
update: updates
	@:

.PHONY: discover
discover:
	./discover_backlog_load.sh
	$(MAKE) dedupe

.PHONY: dedupe
dedupe:
	./discover_backlog_dedupe.sh
	./spotify_delete_duplicates_in_playlist.sh "My Shazam Tracks"

.PHONY: aggregate
aggregate: backup
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
	git push && \
	cd private/ && \
	git push

.PHONY: test
test:
	./validate.sh

.PHONY:
wc:
	./wc.sh
