GO := go
BINARY ?= hcl-templater
VERSION ?= v0.1.0
BUILD ?= .build
BALLS ?= .balls
TGTS ?= \
	linux/amd64 \
	linux/arm64 \
	darwin/arm64
REL_DESC ?= automatic release from Makefile
GH_USER ?= felichita
GH_REPO ?= $(BINARY)

.PHONY: all
all: build balls release

.PHONY: build
build:
	@/usr/bin/env bash -c ' \
		echo ">> building binaries…" ; \
		VER=$$( \
			echo $(VERSION) 2>/dev/null | \
			/usr/bin/env sed -r s/[^a-z0-9]/_/Ig \
		) && \
		/usr/bin/env mkdir -vp "$(BUILD)"; \
		for tgt in $(TGTS); do \
			export GOOS=$${tgt/\/*} ; \
			export GOARCH=$${tgt/*\/} ; \
			echo " > target [$$VER-$$GOOS-$$GOARCH]" && \
			go build -o $(BUILD)/$(BINARY)-$${VER}-$${GOOS}-$${GOARCH} ; \
		done ; \
	'

.PHONY: balls
balls:
	@/usr/bin/env bash -c ' \
		echo ">> building release balls…" ; \
		/usr/bin/env mkdir -vp "$(BALLS)" && \
                VER=$$( \
                        echo $(VERSION) 2>/dev/null | \
                        /usr/bin/env sed -r s/[^a-z0-9]/_/Ig \
                ) && \
		for tgt in $(TGTS); do \
			GOOS=$${tgt/\/*} && \
			GOARCH=$${tgt/*\/} && \
			BALL_PFX="../$(BALLS)/$(BINARY)-$${VER}-$${GOOS}-$${GOARCH}" && \
			echo " > target [$${VER}-$$GOOS-$$GOARCH]" && \
			( \
				cd "$(BUILD)" && \
				/usr/bin/env tar --create \
					--file $${BALL_PFX}.tar \
					$(BINARY)-$${VER}-$${GOOS}-$${GOARCH} && \
				/usr/bin/env pixz $${BALL_PFX}.tar && \
				/usr/bin/env mv -f $${BALL_PFX}.tpxz $${BALL_PFX}.txz ; \
			) \
		done ; \
	'

.PHONY: release
release: get-github-release
	@/usr/bin/env bash -c ' \
		echo ">> pushing binaries to github…" ; \
		if [[ -z "$${GITHUB_TOKEN}" ]]; then \
			echo "Undefined or empty GITHUB_TOKEN environment variable, giving up…"; \
			exit 1; \
		fi; \
                VER=$$( \
                        echo $(VERSION) 2>/dev/null | \
                        /usr/bin/env sed -r s/[^a-z0-9]/_/Ig \
                ) && \
		echo " > creating release [v$(VERSION)] draft" && \
		/usr/bin/env git tag -m '\'''\'' "$(VERSION)" && \
		/usr/bin/env git push origin "$(VERSION)" && \
		/usr/bin/env github-release release \
			--draft \
			-t $(VERSION) \
			-u $(GH_USER) \
			-r $(GH_REPO) \
			-n "$(REL_NAME_PREFIX) $(VERSION) $(REL_NAME_SUFFIX)" \
			-d "$(REL_DESC)" && \
		while ! /usr/bin/env github-release info \
			-t $(VERSION) \
			-u $(GH_USER) \
			-r $(GH_REPO) 2>/dev/null; do \
			echo "  > waiting to release will be ready…"; \
			/usr/bin/env sleep 1; \
		done && \
		for tgt in $(TGTS); do \
			GOOS=$${tgt/\/*} && \
			GOARCH=$${tgt/*\/} && \
			echo "  > arch [$${GOARCH}] for OS [$${GOOS}] uploading" && \
			/usr/bin/env github-release upload \
			-t "$(VERSION)" \
			-u "$(GH_USER)" \
			-r "$(GH_REPO)" \
			-n "$(BINARY)-$${VER}-$${GOOS}-$${GOARCH}.txz" \
			-f "$(BALLS)/$(BINARY)-$${VER}-$${GOOS}-$${GOARCH}.txz" ; \
		done \
	'

.PHONY: get-github-release
get-github-release:
	# command bellow installing previous version for some reason:
	# $(GO) install github.com/github-release/github-release@latest
	@/usr/bin/env bash -c ' \
		if [[ \
			"$$( \
				/usr/bin/env github-release --version 2>&1 | \
					/usr/bin/env awk '\''{print $$2}'\'' \
			)" != '\''v0.10.0'\'' \
		]]; then \
			/usr/bin/env curl -L https://github.com/github-release/github-release/releases/download/v0.10.0/linux-amd64-github-release.bz2 | \
				/usr/bin/env bzip2 -d >"$${GOPATH}/bin/github-release" && \
				/usr/bin/env chmod 755 "$${GOPATH}/bin/github-release" ; \
		fi \
	'

.PHONY: clean
clean:
	@rm -rfv "$(BUILD)" "$(BALLS)"

