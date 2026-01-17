#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_error() {
    echo -e "${RED}Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${BLUE}$1${NC}"
}

install_phpv() {
    print_info "Creating required directories..."
    mkdir -p "$HOME/src"
    mkdir -p "$HOME/bin"

    if [ -f "phpv" ]; then
        print_info "Found a local copy of phpv."
    else
        print_info "Downloading phpv script from GitHub..."
        if ! curl -fsSL -o phpv https://raw.githubusercontent.com/rajabilal555/phpv/refs/heads/main/phpv; then
            print_error "Failed to download phpv script from GitHub."
            exit 1
        fi
    fi

    print_info "Installing script to $HOME/bin/phpv..."
    cp phpv "$HOME/bin/phpv"
    chmod +x "$HOME/bin/phpv"

    print_info "Updating PATH environment variable..."

    update_shell_config() {
        local config_file="$1"
        local shell_name="$2"
        if [ -f "$config_file" ]; then
            if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$config_file"; then
                echo 'export PATH="$HOME/bin:$PATH"' >>"$config_file"
                print_success "Added PATH update to $shell_name."
            else
                print_warning "PATH already configured in $shell_name."
            fi
        else
            print_warning "$config_file not found. Checking next shell configuration file."
        fi
    }

    update_shell_config "$HOME/.bash_profile" "bash profile"
    update_shell_config "$HOME/.bashrc" "bash"
    update_shell_config "$HOME/.zshrc" "zsh"
    update_shell_config "$HOME/.profile" "profile"

    print_info "Reloading shell configuration..."
    source "$HOME/.bash_profile" 2>/dev/null || \
    source "$HOME/.bashrc" 2>/dev/null || \
    source "$HOME/.zshrc" 2>/dev/null || \
    source "$HOME/.profile" 2>/dev/null || true

    if command -v phpv >/dev/null; then
        print_success "Installation complete! PHPV is now ready to use."
    else
        print_error "Installation failed. Please check your PATH configuration."
    fi

    print_info "To use PHPV:"
    print_info "For installation or update: phpv -i <version>"
    print_info "For switching PHP versions: phpv <version>"
}

install_phpv
