SWIFT_PACKAGE := swift package
SWIFT_TEST := $(SWIFT_PACKAGE) test
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format
PROJECT_NAME := RSSReader
XCODE_PROJECT := $(PROJECT_NAME).xcodeproj

.PHONY: test lint lint-fix format clean install-tools setup open project init-packages reset-packages

project: install-tools setup open

setup: init-packages
	@echo "Project dependencies resolved successfully!"

init-packages:
	@echo "Initializing local package dependencies..."
	@if [ -d "RSSReaderKit" ]; then \
		cd RSSReaderKit && $(SWIFT_PACKAGE) resolve && cd ..; \
	fi
	@echo "Local packages initialized"

open:
	@if [ -d "$(XCODE_PROJECT)" ]; then \
		open $(XCODE_PROJECT); \
	elif [ -d "$(PROJECT_NAME).xcworkspace" ]; then \
		open $(PROJECT_NAME).xcworkspace; \
	else \
		echo "No Xcode project or workspace found to open"; \
		exit 1; \
	fi

reset-packages:
	rm -rf .build
	rm -rf *.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
	cd RSSReaderKit && $(SWIFT_PACKAGE) reset && cd ..
	cd RSSReaderKit && $(SWIFT_PACKAGE) resolve && cd ..

test:
	cd RSSReaderKit && $(SWIFT_TEST) && cd ..

lint:
	$(SWIFT_LINT) lint --config .swiftlint.yml

lint-fix:
	$(SWIFT_LINT) --fix --config .swiftlint.yml

format:
	$(SWIFT_FORMAT) format --in-place --recursive ./Sources ./Tests

clean:
	cd RSSReaderKit && $(SWIFT_PACKAGE) clean && cd ..

install-tools:
	brew install swiftlint
	brew install swift-format
