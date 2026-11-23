#!/bin/bash

# Keyboard Layout Switcher Configuration for GNOME (Ubuntu)
# Rebinds the input source (keyboard layout) switcher from the
# default Super+Space / Ctrl+Space to Shift+Alt.
#
# Usage:
#   ./layout-switch.sh            # apply Shift+Alt (left modifiers only)
#   ./layout-switch.sh --both     # apply Shift+Alt (left and right modifiers)
#   ./layout-switch.sh --revert   # restore GNOME defaults
#   ./layout-switch.sh --show     # print the current bindings
#
# Runs as your normal user - do NOT run with sudo, these are
# per-user dconf settings and sudo would write them for root.

SCHEMA="org.gnome.desktop.wm.keybindings"
KEY_FWD="switch-input-source"
KEY_BWD="switch-input-source-backward"

echo "=============================================="
echo "GNOME KEYBOARD LAYOUT SWITCHER"
echo "=============================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to validate the environment
check_environment() {
    if [[ $EUID -eq 0 ]]; then
        echo "This script must NOT be run as root"
        echo "Usage: $0 [--both|--revert|--show]"
        exit 1
    fi

    if ! command_exists gsettings; then
        echo "gsettings not found - this script requires GNOME"
        exit 1
    fi

    if ! gsettings list-schemas | grep -qx "$SCHEMA"; then
        echo "Schema $SCHEMA not available - is this a GNOME session?"
        exit 1
    fi
}

# Function to print the current bindings
show_bindings() {
    echo "Layouts : $(gsettings get org.gnome.desktop.input-sources sources)"
    echo "Forward : $(gsettings get "$SCHEMA" "$KEY_FWD")"
    echo "Backward: $(gsettings get "$SCHEMA" "$KEY_BWD")"
}

# Function to apply the Shift+Alt binding
apply_bindings() {
    local fwd="['<Alt>Shift_L']"
    local bwd="['<Shift>Alt_L']"

    if [[ $1 == "both" ]]; then
        fwd="['<Alt>Shift_L', '<Alt>Shift_R']"
        bwd="['<Shift>Alt_L', '<Shift>Alt_R']"
    fi

    echo "Setting layout switcher to Shift+Alt..."
    gsettings set "$SCHEMA" "$KEY_FWD" "$fwd"
    gsettings set "$SCHEMA" "$KEY_BWD" "$bwd"
}

# Function to restore the GNOME defaults
revert_bindings() {
    echo "Restoring default layout switcher bindings..."
    gsettings reset "$SCHEMA" "$KEY_FWD"
    gsettings reset "$SCHEMA" "$KEY_BWD"
}

check_environment

case "$1" in
    --show)
        show_bindings
        exit 0
        ;;
    --revert)
        revert_bindings
        ;;
    --both)
        apply_bindings both
        ;;
    ""|--left)
        apply_bindings left
        ;;
    *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--both|--revert|--show]"
        exit 1
        ;;
esac

echo ""
echo "Current configuration:"
show_bindings

echo ""
echo "=============================================="
echo "DONE - the change takes effect immediately"
echo "=============================================="
echo "Shift+Alt cycles forward through the layouts,"
echo "Alt+Shift (reverse order) cycles backward."
