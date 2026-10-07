# Per-app Makefile. Every command Claude or a human runs goes through here.
# Run `make help` to list targets.

APP            := __APP_NAME__
SCHEME         := $(APP)
BUNDLE_ID      := __BUNDLE_PREFIX__.$(APP)
DERIVED        := build/DerivedData
RESULTS        := build/results
ENV_FILE       := $(or $(XCODE_DEV_ENV),$(HOME)/.config/xcode-development/env)
XCBEAUTIFY     := $(shell command -v xcbeautify 2>/dev/null || echo cat)
JQ             := jq

# Pick the newest available iPhone and iPad simulators at run time, so this
# file does not break when Xcode renames devices.
SIM_IPHONE ?= $(shell xcrun simctl list devices available -j | $(JQ) -r '[.devices | to_entries[] | select(.key | test("iOS")) | .value[] | select(.name | test("^iPhone")) | .name] | last')
SIM_IPAD   ?= $(shell xcrun simctl list devices available -j | $(JQ) -r '[.devices | to_entries[] | select(.key | test("iOS")) | .value[] | select(.name | test("^iPad")) | .name] | last')

DEST_IPHONE := platform=iOS Simulator,name=$(SIM_IPHONE)
DEST_IPAD   := platform=iOS Simulator,name=$(SIM_IPAD)
DEST_DEVICE := generic/platform=iOS

# Simulator builds never need signing. Keeps CI and headless Macs simple.
NOSIGN := CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

.DEFAULT_GOAL := help
.PHONY: help generate build build-ipad test test-unit test-ui test-ipad lint lint-fix format format-check check \
        run run-ipad screenshot screenshot-ipad install-device sims clean hooks xcode-open

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

generate: Configs/Local.xcconfig ## Generate the .xcodeproj from project.yml
	xcodegen generate --quiet

Configs/Local.xcconfig:
	@mkdir -p Configs
	@if [ -f "$(ENV_FILE)" ] && grep -q '^DEVELOPMENT_TEAM=' "$(ENV_FILE)"; then \
		echo "DEVELOPMENT_TEAM = $$(grep '^DEVELOPMENT_TEAM=' "$(ENV_FILE)" | cut -d= -f2)" > Configs/Local.xcconfig; \
		echo "Wrote Configs/Local.xcconfig from $(ENV_FILE)"; \
	else \
		echo "// No DEVELOPMENT_TEAM set. Simulator builds work; device builds need it." > Configs/Local.xcconfig; \
	fi

build: generate ## Build for the iPhone simulator
	set -o pipefail && xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPHONE)' -derivedDataPath $(DERIVED) $(NOSIGN) build | $(XCBEAUTIFY)

build-ipad: generate ## Build for the iPad simulator
	set -o pipefail && xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPAD)' -derivedDataPath $(DERIVED) $(NOSIGN) build | $(XCBEAUTIFY)

test: generate ## Run unit and UI tests on the iPhone simulator
	@rm -rf $(RESULTS)/iphone.xcresult
	set -o pipefail && NSUnbufferedIO=YES xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPHONE)' -derivedDataPath $(DERIVED) $(NOSIGN) \
		-resultBundlePath $(RESULTS)/iphone.xcresult test | $(XCBEAUTIFY)

test-unit: generate ## Run unit tests only (fast)
	set -o pipefail && NSUnbufferedIO=YES xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPHONE)' -derivedDataPath $(DERIVED) $(NOSIGN) \
		-only-testing:$(APP)Tests test | $(XCBEAUTIFY)

test-ui: generate ## Run UI tests only
	set -o pipefail && NSUnbufferedIO=YES xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPHONE)' -derivedDataPath $(DERIVED) $(NOSIGN) \
		-only-testing:$(APP)UITests test | $(XCBEAUTIFY)

test-ipad: generate ## Run all tests on the iPad simulator
	@rm -rf $(RESULTS)/ipad.xcresult
	set -o pipefail && NSUnbufferedIO=YES xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_IPAD)' -derivedDataPath $(DERIVED) $(NOSIGN) \
		-resultBundlePath $(RESULTS)/ipad.xcresult test | $(XCBEAUTIFY)

lint: ## SwiftLint (strict) and swift-format lint
	swiftlint lint --strict --quiet
	swift format lint --strict --recursive Sources Tests UITests

lint-fix: ## Auto-fix SwiftLint violations where possible
	swiftlint lint --fix --quiet

format: ## Format all Swift sources in place
	swift format format --in-place --recursive Sources Tests UITests

format-check: ## Fail if formatting would change anything
	swift format lint --strict --recursive Sources Tests UITests

check: lint build test ## The definition-of-done gate: lint, build, test

sims: ## List available simulators and the two this Makefile picked
	@echo "iPhone: $(SIM_IPHONE)"
	@echo "iPad:   $(SIM_IPAD)"
	@xcrun simctl list devices available | grep -E 'iPhone|iPad'

run: build ## Boot the iPhone simulator, install, and launch the app
	@scripts/sim-run.sh "$(SIM_IPHONE)" "$(DERIVED)/Build/Products/Debug-iphonesimulator/$(APP).app" "$(BUNDLE_ID)"

run-ipad: build-ipad ## Boot the iPad simulator, install, and launch the app
	@scripts/sim-run.sh "$(SIM_IPAD)" "$(DERIVED)/Build/Products/Debug-iphonesimulator/$(APP).app" "$(BUNDLE_ID)"

screenshot: ## Screenshot the running iPhone simulator to build/screenshots/
	@scripts/sim-screenshot.sh "$(SIM_IPHONE)" build/screenshots

screenshot-ipad: ## Screenshot the running iPad simulator
	@scripts/sim-screenshot.sh "$(SIM_IPAD)" build/screenshots

install-device: generate ## Build signed, install on the first connected device, launch
	set -o pipefail && xcodebuild -project $(APP).xcodeproj -scheme $(SCHEME) \
		-destination '$(DEST_DEVICE)' -derivedDataPath $(DERIVED) -allowProvisioningUpdates build | $(XCBEAUTIFY)
	@scripts/device-install.sh "$(DERIVED)/Build/Products/Debug-iphoneos/$(APP).app" "$(BUNDLE_ID)"

hooks: ## Install git hooks (lefthook)
	lefthook install

xcode-open: generate ## Register this project with Xcode's headless MCP server (or open Xcode)
	xcrun mcp-server open "$(PWD)/$(APP).xcodeproj" 2>/dev/null || open $(APP).xcodeproj

clean: ## Remove build output and the generated project
	rm -rf build $(APP).xcodeproj
