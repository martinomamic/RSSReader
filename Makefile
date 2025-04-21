SWIFT_PACKAGE := swift package
SWIFT_TEST := $(SWIFT_PACKAGE) test
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format

.PHONY: test lint lint-fix format clean install-tools

test:
	$(SWIFT_TEST)

lint:
	$(SWIFT_LINT) lint --config .swiftlint.yml

lint-fix:
	$(SWIFT_LINT) --fix --config .swiftlint.yml


format:
	$(SWIFT_FORMAT) format --in-place --recursive ./Sources ./Tests

clean:
	rm -rf .build
	$(SWIFT_PACKAGE) clean

install-tools:
	brew install swiftlint
	brew install swift-format
