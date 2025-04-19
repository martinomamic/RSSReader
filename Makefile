SWIFT_PACKAGE := swift package
SWIFT_BUILD := $(SWIFT_PACKAGE) build
SWIFT_TEST := $(SWIFT_PACKAGE) test
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format

.PHONY: all
all: lint build test

.PHONY: build
build:
	$(SWIFT_BUILD)

.PHONY: test
test:
	$(SWIFT_TEST)

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
	rm -rf .build
	$(SWIFT_PACKAGE) clean

.PHONY: xcodeproj
xcodeproj:
	$(SWIFT_PACKAGE) generate-xcodeproj

.PHONY: install-tools
install-tools:
	brew install swiftlint
	brew install swift-format