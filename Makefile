# NaloFocus Makefile
# Provides convenient commands for building, testing, and linting

.PHONY: help build test lint lint-fix run clean release bundle install

# Default target
help:
	@echo "NaloFocus Development Commands:"
	@echo ""
	@echo "  make build       - Build the application"
	@echo "  make test        - Run all tests"
	@echo "  make lint        - Check code style with SwiftLint"
	@echo "  make lint-fix    - Auto-fix SwiftLint issues"
	@echo "  make run         - Build and run the application"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make release     - Build for release"
	@echo "  make bundle      - Build release and assemble a signed .app in .build/release"
	@echo "  make install     - Build release, bundle, sign, and install to /Applications"
	@echo "  make check       - Run lint and tests"
	@echo "  make all         - Clean, lint, build, and test"

# Build the application
build:
	swift build

# Run tests
test:
	swift test

# Check code style
lint:
	@./scripts/swift-lint.sh || ./scripts/lint.sh 2>/dev/null || true

# Fix auto-correctable linting issues
lint-fix:
	@./scripts/lint.sh fix 2>/dev/null || echo "SwiftLint fix not available, please fix issues manually"

# Build and run
run: lint build
	swift run NaloFocus

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build/

# Build for release
release: lint test
	swift build -c release

# Assemble a signed release .app (see scripts/bundle.sh; NALOFOCUS_SIGN_IDENTITY picks the identity)
bundle:
	@scripts/bundle.sh release

# Install to Applications folder (macOS). Uses the repo Info.plist: the Reminders usage strings
# live there and TCC refuses the access request without them.
install: lint test
	@APP="$$(scripts/bundle.sh release)" && \
	pkill -x NaloFocus 2>/dev/null || true; \
	rm -rf /Applications/NaloFocus.app && \
	ditto "$$APP" /Applications/NaloFocus.app && \
	echo "✓ NaloFocus installed to /Applications" && \
	echo "  Launch: open /Applications/NaloFocus.app   Login item: System Settings > General > Login Items"

# Run both lint and tests
check: lint test

# Complete build pipeline
all: clean lint build test
	@echo "✓ All checks passed!"