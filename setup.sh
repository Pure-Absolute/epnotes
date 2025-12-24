#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
}

# Print colored messages
print_info() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_info "Checking dependencies..."
    
    if ! command -v g++ &> /dev/null; then
        print_error "g++ not found. Please install a C++ compiler."
        exit 1
    fi
    
    # Check for ncurses based on OS
    case $OS in
        linux)
            if ! ldconfig -p | grep -q libncurses; then
                print_error "ncurses not found. Install with: sudo apt install libncurses-dev (Debian/Ubuntu) or sudo yum install ncurses-devel (RedHat/Fedora)"
                exit 1
            fi
            ;;
        macos)
            if ! brew list ncurses &> /dev/null 2>&1; then
                print_warning "ncurses not found via Homebrew. Trying system ncurses..."
            fi
            ;;
    esac
    
    print_success "All dependencies satisfied"
}

# Build the application
build_app() {
    print_info "Building EP Notes..."
    
    case $OS in
        linux|macos)
            g++ -std=c++17 src/epnotes.cpp -o epnotes -lncurses
            ;;
        windows)
            g++ -std=c++17 src/epnotes.cpp -o epnotes.exe -lpdcurses
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_success "Build successful"
    else
        print_error "Build failed"
        exit 1
    fi
}

# Install binary
install_binary() {
    print_info "Installing binary..."
    
    case $OS in
        linux)
            if [ -w /usr/local/bin ]; then
                install -Dm755 epnotes /usr/local/bin/epnotes
            else
                sudo install -Dm755 epnotes /usr/local/bin/epnotes
            fi
            print_success "Binary installed to /usr/local/bin/epnotes"
            ;;
        macos)
            if [ -w /usr/local/bin ]; then
                install -m755 epnotes /usr/local/bin/epnotes
            else
                sudo install -m755 epnotes /usr/local/bin/epnotes
            fi
            print_success "Binary installed to /usr/local/bin/epnotes"
            ;;
        windows)
            mkdir -p ~/bin 2>/dev/null || true
            cp epnotes.exe ~/bin/
            print_success "Binary installed to ~/bin/epnotes.exe"
            print_warning "Add ~/bin to your PATH if not already added"
            ;;
    esac
}

# Install desktop integration (Linux only)
install_desktop_integration() {
    if [ "$OS" != "linux" ]; then
        return
    fi
    
    print_info "Installing desktop integration..."
    
    # Install MIME type
    if command -v xdg-mime &> /dev/null; then
        if [ -f ./setupfiles/pure-epnotes.xml ]; then
            xdg-mime install --novendor ./setupfiles/pure-epnotes.xml
            
            # Update MIME database
            if [ -d ~/.local/share/mime ]; then
                update-mime-database ~/.local/share/mime 2>/dev/null || true
            fi
            
            print_success "MIME type installed"
        else
            print_warning "MIME type file not found, skipping..."
        fi
        
        # Install desktop entry
        if [ -f ./setupfiles/epnotes.desktop ]; then
            mkdir -p ~/.local/share/applications
            install -Dm644 ./setupfiles/epnotes.desktop ~/.local/share/applications/epnotes.desktop
            
            # Set as default for .epnotes files
            xdg-mime default epnotes.desktop application/x-epnotes
            
            print_success "Desktop entry installed"
        else
            print_warning "Desktop entry file not found, skipping..."
        fi
    else
        print_warning "xdg-mime not found, skipping desktop integration"
    fi
}

# macOS specific integration
install_macos_integration() {
    if [ "$OS" != "macos" ]; then
        return
    fi
    
    print_info "Setting up macOS integration..."
    
    # Create a simple app bundle if needed
    print_warning "macOS integration limited. Consider creating an app bundle manually."
}

# Main installation
main() {
    echo ""
    echo "=========================================="
    echo "       EP Notes Installer"
    echo "=========================================="
    echo ""
    
    detect_os
    print_info "Detected OS: $OS"
    
    if [ "$OS" == "unknown" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    check_dependencies
    build_app
    install_binary
    install_desktop_integration
    install_macos_integration
    
    echo ""
    echo "=========================================="
    print_success "EP Notes installed successfully!"
    echo "=========================================="
    echo ""
    
    case $OS in
        linux|macos)
            echo "Run 'epnotes <file.epnotes>' to start"
            ;;
        windows)
            echo "Run 'epnotes.exe <file.epnotes>' to start"
            ;;
    esac
    
    echo ""
}

# Run main function
main




