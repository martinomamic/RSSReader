SWIFT_PACKAGE := swift package
SWIFT_BUILD := $(SWIFT_PACKAGE) build
SWIFT_TEST := $(SWIFT_PACKAGE) test
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format

PACKAGE_DIR = RSSReaderKit
SCHEME = RSSReader
TEST_PLAN = RSSReader
CONFIGURATION = Debug

.PHONY: all
all: package-build build

.PHONY: build
build:
	xcodebuild \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		build

.PHONY: test
test:
	xcodebuild \
		-scheme $(SCHEME) \
		-testPlan $(TEST_PLAN) \
		-configuration $(CONFIGURATION) \
		-resultBundlePath TestResults/App \
		test

.PHONY: lint
lint:
	$(SWIFT_LINT) lint --config .swiftlint.yml

.PHONY: lint-fix
lint-fix:
	$(SWIFT_LINT) --fix --config .swiftlint.yml

.PHONY: format
format:
	$(SWIFT_FORMAT) format --in-place --recursive ./Sources ./Tests

.PHONY: clean
clean:
	rm -rf build
	rm -rf TestResults
	cd $(PACKAGE_DIR) && swift package clean

.PHONY: xcodeproj
xcodeproj:
	$(SWIFT_PACKAGE) generate-xcodeproj

.PHONY: install-tools
install-tools:
	brew install swiftlint
	brew install swift-format

.PHONY: package-build
package-build:
	cd $(PACKAGE_DIR) && swift build

.PHONY: package-test
package-test:
	cd $(PACKAGE_DIR) && swift test

.PHONY: test-all
test-all:
	@echo "Running package tests..."
	@cd $(PACKAGE_DIR) && swift test || (echo "❌ Package tests failed" && exit 1)
	@echo "✅ Package tests passed"
	@echo "Running app tests..."
	@xcodebuild \
		-scheme $(SCHEME) \
		-testPlan $(TEST_PLAN) \
		-configuration $(CONFIGURATION) \
		-resultBundlePath TestResults/App \
		test || (echo "❌ App tests failed" && exit 1)
	@echo "✅ App tests passed"

.PHONY: ci
ci: test-all
