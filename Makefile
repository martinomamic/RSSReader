SWIFT_PACKAGE := swift package
SWIFT_LINT := swiftlint
SWIFT_FORMAT := swift-format
PROJECT_NAME := RSSReader
XCODE_PROJECT := $(PROJECT_NAME).xcodeproj
TEST_RESULT_PATH := $(CURDIR)/TestResults.xcresult

.PHONY: test lint lint-fix format clean install-tools setup open project init-packages reset-packages build xcode-clean help

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

build:
	xcodebuild build -project $(XCODE_PROJECT) -scheme $(PROJECT_NAME)
	
install-tools:
	@echo "Checking if swiftlint is installed..."
	@if ! command -v swiftlint &> /dev/null; then \
		echo "Installing swiftlint..."; \
		brew install swiftlint; \
	else \
		echo "swiftlint already installed"; \
	fi
	@echo "Checking if swift-format is installed..."
	@if ! command -v swift-format &> /dev/null; then \
		echo "Installing swift-format..."; \
		brew install swift-format; \
	else \
		echo "swift-format already installed"; \
	fi
	@echo "Checking if jq is installed..."
	@if ! command -v jq &> /dev/null; then \
		echo "Installing jq..."; \
		brew install jq; \
	else \
		echo "jq already installed"; \
	fi

test:
	@echo "Removing previous test results..."
	rm -rf $(TEST_RESULT_PATH)
	@echo "Running tests and generating result bundle..."
	xcodebuild test -project $(XCODE_PROJECT) -scheme $(PROJECT_NAME) -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' -resultBundlePath $(TEST_RESULT_PATH) -enableCodeCoverage YES
	@echo "\nTest summary:"
	@xcrun xcresulttool get test-results summary --path $(TEST_RESULT_PATH) --compact | \
	jq '{totalTests: .totalTestCount, passed: .passedTests, failed: .failedTests, skipped: .skippedTests, expectedFailures: .expectedFailures, duration: (.result | if type=="object" then .testDuration else null end)}'
	@echo "\nGenerating coverage report..."
	@xcrun xccov view --report $(TEST_RESULT_PATH) --json | \
	jq '{coverage: .lineCoverage, targets: [.targets[] | {name: .name, coverage: .lineCoverage, functions: .functionCoverage}]}' | \
	jq -r '"Overall Coverage: " + ((.coverage * 100) | tostring | .[0:5]) + "%"'

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
	@echo "  make test 				- Runs tests, and adds a simple summary and code coverage"
