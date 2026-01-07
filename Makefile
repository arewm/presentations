# Makefile for Jekyll presentations

# Find bundle from Homebrew or system, preferring Homebrew
BUNDLE := $(shell command -v /opt/homebrew/opt/ruby/bin/bundle 2>/dev/null || command -v bundle)

.PHONY: install
install:
	$(BUNDLE) install

.PHONY: serve
serve:
	$(BUNDLE) exec jekyll serve

.PHONY: build
build:
	$(BUNDLE) exec jekyll build

.PHONY: clean
clean:
	rm -rf _site/

.PHONY: update-remark
update-remark:
	mkdir -p shared/js
	curl -sL https://remarkjs.com/downloads/remark-latest.min.js -o shared/js/remark.min.js
