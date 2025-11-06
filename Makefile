# NaloFocus Makefile
# Provides convenient commands for building, testing, and linting

.PHONY: help build test lint lint-fix run clean release install

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
	@echo "  make install     - Build release and install to /Applications"
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

# Install to Applications folder (macOS)
install: release
	@echo "Building app bundle..."
	@mkdir -p /tmp/NaloFocus.app/Contents/MacOS
	@mkdir -p /tmp/NaloFocus.app/Contents/Resources
	@cp .build/release/NaloFocus /tmp/NaloFocus.app/Contents/MacOS/
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > /tmp/NaloFocus.app/Contents/Info.plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '<plist version="1.0">' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '<dict>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <key>CFBundleExecutable</key>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <string>NaloFocus</string>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <key>CFBundleIdentifier</key>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <string>com.nalofocus.app</string>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <key>CFBundleName</key>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <string>NaloFocus</string>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <key>CFBundlePackageType</key>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <string>APPL</string>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <key>LSUIElement</key>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '    <true/>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '</dict>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@echo '</plist>' >> /tmp/NaloFocus.app/Contents/Info.plist
	@rm -rf /Applications/NaloFocus.app
	@mv /tmp/NaloFocus.app /Applications/
	@echo "✓ NaloFocus installed to /Applications"

# Run both lint and tests
check: lint test

# Complete build pipeline
all: clean lint build test
	@echo "✓ All checks passed!"