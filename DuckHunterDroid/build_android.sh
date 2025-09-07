#!/bin/bash

# Duck Hunter Android - Build Script
# Build Android APK from command line

set -e  # Exit on any error

echo "🤖 Duck Hunter Android - Build Script"
echo "===================================="

# Configuration
PROJECT_DIR="/Users/admin/Downloads/Xcode Projects/RYANFUCH/DuckHunterDroid"
BUILD_DIR="$PROJECT_DIR/build"
APK_DIR="$BUILD_DIR/outputs/apk"
GRADLE="./gradlew"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check dependencies
check_deps() {
    log_step "Checking dependencies..."

    # Check Java
    if ! command -v java &> /dev/null; then
        log_error "Java not found. Please install JDK 11+."
        exit 1
    fi

    # Check Android SDK (basic check)
    if [ -z "$ANDROID_HOME" ]; then
        log_warn "ANDROID_HOME not set. Using default detection..."
    fi

    # Check gradle wrapper
    if [ ! -f "$GRADLE" ]; then
        log_error "Gradle wrapper not found at $GRADLE"
        exit 1
    fi

    log_info "Dependencies OK ✓"
}

# Setup Android SDK (if needed)
setup_sdk() {
    log_step "Setting up Android SDK..."

    # This is a basic setup - in production you'd want more comprehensive SDK management
    if [ -z "$ANDROID_HOME" ]; then
        # Try to find Android SDK in common locations
        POSSIBLE_LOCATIONS=(
            "$HOME/Library/Android/sdk"
            "$HOME/Android/Sdk"
            "/opt/android-sdk"
            "/usr/local/android-sdk"
        )

        for location in "${POSSIBLE_LOCATIONS[@]}"; do
            if [ -d "$location" ]; then
                export ANDROID_HOME="$location"
                log_info "Found Android SDK at: $ANDROID_HOME"
                break
            fi
        done

        if [ -z "$ANDROID_HOME" ]; then
            log_warn "Android SDK not found automatically."
            log_info "Please set ANDROID_HOME or install Android SDK."
            log_info "Download from: https://developer.android.com/studio"
        fi
    fi
}

# Clean build
clean_build() {
    log_step "Cleaning previous build..."
    cd "$PROJECT_DIR"
    $GRADLE clean
    log_info "Clean complete ✓"
}

# Build debug APK
build_debug() {
    log_step "Building debug APK..."
    cd "$PROJECT_DIR"
    $GRADLE assembleDebug
    log_info "Debug build complete ✓"
}

# Build release APK
build_release() {
    log_step "Building release APK..."
    cd "$PROJECT_DIR"
    $GRADLE assembleRelease
    log_info "Release build complete ✓"
}

# Install on connected device
install_device() {
    log_step "Installing on connected device..."

    if ! command -v adb &> /dev/null; then
        log_error "ADB not found. Please install Android SDK platform tools."
        exit 1
    fi

    # Find APK
    DEBUG_APK="$APK_DIR/debug/app-debug.apk"
    RELEASE_APK="$APK_DIR/release/app-release.apk"

    if [ -f "$DEBUG_APK" ]; then
        APK_FILE="$DEBUG_APK"
        log_info "Using debug APK"
    elif [ -f "$RELEASE_APK" ]; then
        APK_FILE="$RELEASE_APK"
        log_info "Using release APK"
    else
        log_error "No APK found. Run build first."
        exit 1
    fi

    # Install APK
    adb install -r "$APK_FILE"

    if [ $? -eq 0 ]; then
        log_info "Installation successful ✓"

        # Launch app
        adb shell monkey -p com.duckhunter.android -c android.intent.category.LAUNCHER 1
        log_info "App launched on device ✓"
    else
        log_error "Installation failed"
    fi
}

# List connected devices
list_devices() {
    log_step "Listing connected devices..."
    if command -v adb &> /dev/null; then
        adb devices
    else
        log_error "ADB not found"
    fi
}

# Show APK info
show_apk_info() {
    log_step "APK Information..."

    DEBUG_APK="$APK_DIR/debug/app-debug.apk"
    RELEASE_APK="$APK_DIR/release/app-release.apk"

    if [ -f "$DEBUG_APK" ]; then
        log_info "Debug APK: $DEBUG_APK"
        ls -lh "$DEBUG_APK"
    fi

    if [ -f "$RELEASE_APK" ]; then
        log_info "Release APK: $RELEASE_APK"
        ls -lh "$RELEASE_APK"
    fi
}

# Run tests
run_tests() {
    log_step "Running tests..."
    cd "$PROJECT_DIR"
    $GRADLE test
    log_info "Tests complete ✓"
}

# Full build and install
full_build() {
    log_step "Full build and install process..."
    check_deps
    setup_sdk
    clean_build
    build_debug
    show_apk_info
    install_device
    log_info "Full build complete! 🎯"
}

# Show usage
show_usage() {
    echo ""
    echo "🎯 Duck Hunter Android Build Options"
    echo "==================================="
    echo "1. Check dependencies"
    echo "2. Setup Android SDK"
    echo "3. Clean build"
    echo "4. Build debug APK"
    echo "5. Build release APK"
    echo "6. Install on device"
    echo "7. List connected devices"
    echo "8. Show APK info"
    echo "9. Run tests"
    echo "10. Full build (build + install)"
    echo "11. Help"
    echo "0. Exit"
    echo ""
}

# Main menu
main() {
    while true; do
        show_usage
        read -p "Choose an option (0-11): " choice

        case $choice in
            1)
                check_deps
                ;;
            2)
                setup_sdk
                ;;
            3)
                clean_build
                ;;
            4)
                build_debug
                ;;
            5)
                build_release
                ;;
            6)
                install_device
                ;;
            7)
                list_devices
                ;;
            8)
                show_apk_info
                ;;
            9)
                run_tests
                ;;
            10)
                full_build
                ;;
            11)
                echo ""
                echo "Help:"
                echo "- Make sure Android SDK is installed"
                echo "- Set ANDROID_HOME environment variable"
                echo "- Connect Android device or start emulator"
                echo "- Enable USB debugging on device"
                echo ""
                ;;
            0)
                log_info "Goodbye! 🦆"
                exit 0
                ;;
            *)
                log_error "Invalid option"
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main menu with argument support
if [ $# -gt 0 ]; then
    case $1 in
        "clean")
            clean_build
            ;;
        "debug")
            build_debug
            ;;
        "release")
            build_release
            ;;
        "install")
            install_device
            ;;
        "full")
            full_build
            ;;
        "test")
            run_tests
            ;;
        *)
            log_error "Unknown argument: $1"
            echo "Usage: $0 [clean|debug|release|install|full|test]"
            exit 1
            ;;
    esac
else
    main
fi
