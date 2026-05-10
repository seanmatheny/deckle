# Deckle — macOS Application build
#
# Usage:
#   make app          — release build → Deckle.app in the repo root
#   make app-debug    — debug build
#   make install      — copy Deckle.app to ~/Applications
#   make clean        — remove build artefacts
#
# Opening Package.swift in Xcode also produces a proper .app automatically.

BINARY_NAME   := Deckle
BUNDLE_NAME   := $(BINARY_NAME).app
CONTENTS      := $(BUNDLE_NAME)/Contents
MACOS_DIR     := $(CONTENTS)/MacOS
RESOURCES_DIR := $(CONTENTS)/Resources
PLIST_SRC     := Sources/DeckleApp/Info.plist

.PHONY: app app-debug install clean

app:
	swift build -c release
	$(MAKE) _bundle BUILD_DIR=.build/release

app-debug:
	swift build
	$(MAKE) _bundle BUILD_DIR=.build/debug

_bundle:
	rm -rf "$(BUNDLE_NAME)"
	mkdir -p "$(MACOS_DIR)" "$(RESOURCES_DIR)"
	cp "$(BUILD_DIR)/$(BINARY_NAME)" "$(MACOS_DIR)/$(BINARY_NAME)"
	cp "$(PLIST_SRC)" "$(CONTENTS)/Info.plist"
	@echo "✅  $(BUNDLE_NAME) is ready."

install: app
	mkdir -p ~/Applications
	rm -rf ~/Applications/$(BUNDLE_NAME)
	cp -R $(BUNDLE_NAME) ~/Applications/
	@echo "✅  Installed to ~/Applications/$(BUNDLE_NAME)"

clean:
	swift package clean
	rm -rf "$(BUNDLE_NAME)"
