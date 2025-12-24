#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

uninstall_binary() {
    print_info "Removing binary..."
    
    case $OS in
        linux|macos)
            if [ -f /usr/local/bin/epnotes ]; then
                if [ -w /usr/local/bin ]; then
                    rm /usr/local/bin/epnotes
                else
                    sudo rm /usr/local/bin/epnotes
                fi
                print_success "Binary removed"
            else
                print_warning "Binary not found"
            fi
            ;;
        windows)
            if [ -f ~/bin/epnotes.exe ]; then
                rm ~/bin/epnotes.exe
                print_success "Binary removed"
            else
                print_warning "Binary not found"
            fi
            ;;
    esac
}

uninstall_desktop_integration() {
    if [ "$OS" != "linux" ]; then
        return
    fi
    
    print_info "Removing desktop integration..."
    
    # Remove desktop entry
    if [ -f ~/.local/share/applications/epnotes.desktop ]; then
        rm ~/.local/share/applications/epnotes.desktop
        print_success "Desktop entry removed"
    fi
    
    # Remove MIME type
    if [ -d ~/.local/share/mime/packages ]; then
        if [ -f ~/.local/share/mime/packages/pure-epnotes.xml ]; then
            rm ~/.local/share/mime/packages/pure-epnotes.xml
            update-mime-database ~/.local/share/mime 2>/dev/null || true
            print_success "MIME type removed"
        fi
    fi
}

main() {
    echo ""
    echo "=========================================="
    echo "       EP Notes Uninstaller"
    echo "=========================================="
    echo ""
    
    detect_os
    print_info "Detected OS: $OS"
    
    if [ "$OS" == "unknown" ]; then
        print_error "Unsupported operating system"
        exit 1
    fi
    
    uninstall_binary
    uninstall_desktop_integration
    
    echo ""
    echo "=========================================="
    print_success "EP Notes uninstalled successfully!"
    echo "=========================================="
    echo ""
}

main
