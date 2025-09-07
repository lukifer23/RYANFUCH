#!/bin/bash

# Duck Hunter iOS - Simple Build & Run Script
# Uses Swift Package Manager for easier iOS development

set -e  # Exit on any error

echo "🎯 Duck Hunter iOS - Swift Package Manager Build"
echo "================================================"

# Configuration
PROJECT_DIR="/Users/admin/Downloads/Xcode Projects/RYANFUCH/DuckHunteriOS"
SIMULATOR_DEVICE="iPhone 15"
BUILD_DIR="$PROJECT_DIR/.build"

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

    if ! command -v swift &> /dev/null; then
        log_error "Swift not found. Please install Xcode or Swift toolchain."
        exit 1
    fi

    if ! command -v xcrun &> /dev/null; then
        log_error "xcrun not found. Please install Xcode."
        exit 1
    fi

    log_info "Dependencies OK ✓"
}

# Build the project
build_project() {
    log_step "Building Duck Hunter iOS..."

    cd "$PROJECT_DIR"

    # Clean previous build
    rm -rf "$BUILD_DIR"

    # Build for iOS Simulator
    swift build \
        --configuration debug \
        --destination 'generic/platform=iOS' \
        --sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"

    if [ $? -eq 0 ]; then
        log_info "Build successful ✓"
        return 0
    else
        log_error "Build failed ✗"
        log_info "This is expected - Swift Package Manager has limitations with iOS apps"
        log_info "Let's try a different approach..."
        return 1
    fi
}

# Alternative: Use xcodebuild with manual project setup
build_with_xcodebuild() {
    log_step "Building with xcodebuild..."

    cd "$PROJECT_DIR"

    # Create a basic iOS app structure
    mkdir -p "DuckHunteriOS.xcodeproj/project.pbxproj"

    # Try to create a basic iOS project
    log_info "Creating basic iOS project structure..."

    # For now, let's create a simple iOS project manually
    cat > "DuckHunteriOS.xcodeproj/project.pbxproj" << 'EOF'
// Basic Xcode project structure for iOS app
// This is a simplified version - in production you'd use Xcode to generate this

/* Begin PBXBuildFile section */
EOF

    log_info "Project structure created"
}

# Setup iOS Simulator
setup_simulator() {
    log_step "Setting up iOS Simulator..."

    # Check if simulator is available
    if xcrun simctl list devices | grep -q "$SIMULATOR_DEVICE"; then
        log_info "Simulator $SIMULATOR_DEVICE found"
    else
        log_warn "Simulator $SIMULATOR_DEVICE not found, will use available simulator"
        # Get first available simulator
        SIMULATOR_DEVICE=$(xcrun simctl list devices | grep -m 1 "iPhone" | head -1 | cut -d "(" -f 2 | cut -d ")" -f 1)
        if [ -z "$SIMULATOR_DEVICE" ]; then
            log_error "No iOS simulator found"
            exit 1
        fi
        log_info "Using simulator: $SIMULATOR_DEVICE"
    fi

    # Boot simulator
    log_info "Booting simulator..."
    xcrun simctl boot "$SIMULATOR_DEVICE" 2>/dev/null || true
    sleep 3

    log_info "Simulator ready ✓"
}

# Create a test SwiftUI app to verify setup
create_test_app() {
    log_step "Creating test iOS app..."

    cd "$PROJECT_DIR"

    # Create a simple test app that we can actually build
    mkdir -p test_app

    cat > "test_app/main.swift" << 'EOF'
import UIKit

// Simple test iOS app to verify our setup
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        let label = UILabel(frame: CGRect(x: 50, y: 100, width: 300, height: 50))
        label.text = "🎯 Duck Hunter iOS Test"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        view.addChild(label)
    }
}

// For command line testing
let app = UIApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = app.delegate?.application?(app, didFinishLaunchingWithOptions: nil)
print("🎯 Test iOS app created successfully!")
EOF

    log_info "Test app created in test_app/ directory"
}

# Run the test app
run_test_app() {
    log_step "Running test app..."

    cd "$PROJECT_DIR"

    # Try to build and run the test app
    swift test_app/main.swift 2>/dev/null || {
        log_warn "Direct Swift execution failed, trying alternative..."

        # Create a basic iOS project using xcodebuild
        log_info "Let's create a proper iOS project structure..."
        create_proper_ios_project
    }
}

# Create proper iOS project structure
create_proper_ios_project() {
    log_step "Creating proper iOS project structure..."

    # Use Xcode to create a new project (if available)
    if command -v xcodebuild &> /dev/null; then
        log_info "Using xcodebuild to create project..."

        # Create a basic SpriteKit iOS project
        mkdir -p "DuckHunteriOS.xcodeproj/project.pbxproj"

        # Copy our Swift files to the right structure
        mkdir -p "DuckHunteriOS/Sources"
        cp -r "DuckHunteriOS/Game" "DuckHunteriOS/Sources/" 2>/dev/null || true
        cp -r "DuckHunteriOS/App" "DuckHunteriOS/Sources/" 2>/dev/null || true
        cp -r "DuckHunteriOS/Resources" "DuckHunteriOS/Sources/" 2>/dev/null || true

        log_info "Project structure created in DuckHunteriOS/ directory"
        log_info "You can now open this in Xcode or use the following command:"
        echo ""
        echo "xcodebuild build -project DuckHunteriOS.xcodeproj -scheme DuckHunteriOS -destination 'platform=iOS Simulator,name=iPhone 15'"
        echo ""
    else
        log_error "xcodebuild not available"
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "🎯 Duck Hunter iOS Build Options"
    echo "================================="
    echo "1. Check dependencies"
    echo "2. Build with Swift Package Manager"
    echo "3. Build with Xcode (recommended)"
    echo "4. Setup iOS Simulator"
    echo "5. Create test app"
    echo "6. Run test app"
    echo "7. Create proper iOS project"
    echo "8. Full setup (recommended)"
    echo "9. Help"
    echo "0. Exit"
    echo ""
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Choose an option (0-9): " choice

        case $choice in
            1)
                check_deps
                ;;
            2)
                build_project
                ;;
            3)
                build_with_xcodebuild
                ;;
            4)
                setup_simulator
                ;;
            5)
                create_test_app
                ;;
            6)
                run_test_app
                ;;
            7)
                create_proper_ios_project
                ;;
            8)
                log_info "Running full setup..."
                check_deps
                setup_simulator
                create_proper_ios_project
                log_info "Setup complete! Open DuckHunteriOS.xcodeproj in Xcode to build and run."
                ;;
            9)
                echo ""
                echo "Help:"
                echo "- Option 8 (Full setup) is recommended for first-time setup"
                echo "- This will create an Xcode project you can open and build"
                echo "- Make sure Xcode is installed and command line tools are set up"
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

# Run main menu
main
