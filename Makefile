SWIFT_PACKAGE := swift package
SWIFT_TEST := $(SWIFT_PACKAGE) test
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format
PROJECT_NAME := RSSReader
XCODE_PROJECT := $(PROJECT_NAME).xcodeproj

.PHONY: test lint lint-fix format clean install-tools setup open project init-packages reset-packages build test-coverage xcode-clean help

project: install-tools setup open

renew: xcode-clean clean reset-packages project

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

lint:
	$(SWIFT_LINT) lint --config .swiftlint.yml

lint-fix:
	$(SWIFT_LINT) --fix --config .swiftlint.yml

format:
	$(SWIFT_FORMAT) format --in-place --recursive ./Sources ./Tests

clean:
	cd RSSReaderKit && $(SWIFT_PACKAGE) clean && cd ..

xcode-clean:
	xcodebuild clean -project $(XCODE_PROJECT) -scheme $(PROJECT_NAME)
	rm -rf ~/Library/Developer/Xcode/DerivedData/*

install-tools:
	brew install swiftlint
	brew install swift-format

build:
	xcodebuild build -project $(XCODE_PROJECT) -scheme $(PROJECT_NAME)

help:
	@echo "Available commands:"
	@echo "  make project 			- Runs install tools, setup, open"
	@echo "  make renew 			- Runs xcode-clean, clean, reset-packages, project"
	@echo "  make setup        		- Initialize project dependencies"
	@echo "  make open         		- Open project in Xcode"
	@echo "  make lint         		- Run SwiftLint"
	@echo "  make lint-fix     		- Fix SwiftLint violations"
	@echo "  make format       		- Format code using swift-format"
	@echo "  make clean        		- Clean Swift package"
	@echo "  make xcode-clean  		- Clean Xcode project and derived data"
	@echo "  make build        		- Build project"
	@echo "  make reset-packages 	- Reset package dependencies"
	@echo "  make install-tools 	- Install development tools"
