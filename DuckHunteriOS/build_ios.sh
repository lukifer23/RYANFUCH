#!/bin/bash

# Duck Hunter iOS - Build Script
# Build and run iOS app from command line

set -e  # Exit on any error

echo "🎯 Duck Hunter iOS Build Script"
echo "================================"

# Configuration
PROJECT_DIR="/Users/admin/Downloads/Xcode Projects/RYANFUCH/DuckHunteriOS"
PROJECT_NAME="DuckHunteriOS"
SCHEME_NAME="DuckHunteriOS"
BUILD_DIR="$PROJECT_DIR/build"
SIMULATOR_DEVICE="iPhone 15"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
cd "$PROJECT_DIR"

# Check for required tools
check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v xcodebuild &> /dev/null; then
        log_error "xcodebuild not found. Please install Xcode."
        exit 1
    fi

    if ! command -v xcrun &> /dev/null; then
        log_error "xcrun not found. Please install Xcode command line tools."
        exit 1
    fi

    log_info "Dependencies OK ✓"
}

# Create Xcode project if it doesn't exist
create_xcode_project() {
    if [ ! -d "$PROJECT_NAME.xcodeproj" ]; then
        log_info "Creating Xcode project..."

        # Create a basic iOS SpriteKit project
        xcodebuild -create-xcframework \
            -project "$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME_NAME" \
            2>/dev/null || true

        # Actually, let's use a simpler approach and create the project manually
        mkdir -p "$PROJECT_NAME.xcodeproj"
        mkdir -p "$PROJECT_NAME.xcodeproj/project.xcworkspace"

        log_info "Xcode project structure created"
    else
        log_info "Xcode project already exists"
    fi
}

# Build the project
build_project() {
    log_info "Building project..."

    # Clean previous build
    xcodebuild clean -project "$PROJECT_NAME.xcodeproj" -scheme "$SCHEME_NAME" -configuration Debug

    # Build for iOS Simulator
    xcodebuild build \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$SIMULATOR_DEVICE,OS=latest" \
        BUILD_DIR="$BUILD_DIR"

    if [ $? -eq 0 ]; then
        log_info "Build successful ✓"
    else
        log_error "Build failed ✗"
        exit 1
    fi
}

# Launch simulator and run app
run_simulator() {
    log_info "Launching iOS Simulator..."

    # Boot simulator if not already running
    xcrun simctl boot "$SIMULATOR_DEVICE" 2>/dev/null || true

    # Wait a moment for simulator to boot
    sleep 2

    # Install and launch the app
    APP_PATH="$BUILD_DIR/Debug-iphonesimulator/$PROJECT_NAME.app"

    if [ -d "$APP_PATH" ]; then
        xcrun simctl install booted "$APP_PATH"
        xcrun simctl launch booted "com.duckhunter.ios"

        log_info "App launched on simulator ✓"
        log_info "Press Ctrl+C to stop the simulator"
        wait
    else
        log_error "App not found at $APP_PATH"
        exit 1
    fi
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"
    log_info "Clean complete ✓"
}

# Show usage
show_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     - Build the project"
    echo "  run       - Build and run on simulator"
    echo "  clean     - Clean build artifacts"
    echo "  setup     - Initial project setup"
    echo "  all       - Full build and run cycle"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run"
    echo "  $0 clean"
    echo "  $0 all"
}

# Main script logic
main() {
    case "${1:-all}" in
        "setup")
            check_dependencies
            create_xcode_project
            ;;
        "build")
            check_dependencies
            create_xcode_project
            build_project
            ;;
        "run")
            check_dependencies
            create_xcode_project
            build_project
            run_simulator
            ;;
        "clean")
            clean_build
            ;;
        "all")
            check_dependencies
            create_xcode_project
            build_project
            run_simulator
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
