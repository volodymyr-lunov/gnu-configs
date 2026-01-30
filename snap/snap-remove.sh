#!/bin/bash

# Complete Snap Removal Script for Ubuntu
# This script removes Snap completely from Ubuntu system,
# including all dependencies and prevents automatic reinstallation

echo "=============================================="
echo "SNAP REMOVAL SCRIPT FOR UBUNTU"
echo "=============================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   echo "Usage: sudo $0"
   exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to stop snap services
stop_snap_services() {
    echo "Stopping Snap services..."
    systemctl stop snapd
    systemctl stop snapd.apparmor
    systemctl stop snapd.seeded
    systemctl stop snapd.autoimport
    systemctl stop snapd.recovery
    systemctl stop snapd.system-shutdown
    systemctl stop snapd.socket
    systemctl stop snapd.snap-repair.service
    systemctl stop snapd.snap-repair.timer
    systemctl stop snapd.snap-repair.service
    systemctl stop snapd.snap-repair.timer
}

# Function to remove snap packages
remove_snap_packages() {
    echo "Removing Snap packages..."
    
    # Remove snap packages
    apt remove --purge -y snapd gnome-software-plugin-snap snapd-xdg-open
    
    # Remove any remaining snap packages
    for pkg in $(dpkg -l | grep -E "snapd|snapd-xdg-open|gnome-software-plugin-snap" | awk '{print $2}'); do
        if [[ $pkg != "" ]]; then
            apt remove --purge -y "$pkg"
        fi
    done
    
    # Remove snap packages from apt sources
    rm -f /etc/apt/sources.list.d/ubuntu-snap.list
    rm -f /etc/apt/sources.list.d/snapd.list
    rm -f /etc/apt/sources.list.d/snapd.sources
    rm -f /etc/apt/sources.list.d/ubuntu-snap.sources
    
    # Remove snap directory
    rm -rf /var/lib/snapd
    rm -rf /var/snap
    rm -rf /snap
    rm -rf /etc/snapd
}

# Function to remove snap-related dependencies
remove_snap_dependencies() {
    echo "Removing Snap dependencies..."
    
    # Remove snap-related packages that may have been installed as dependencies
    apt remove --purge -y squashfuse
    apt remove --purge -y snapd
    apt remove --purge -y gnome-software-plugin-snap
    apt remove --purge -y snapd-xdg-open
    apt remove --purge -y snapd-core
    apt remove --purge -y snapd-core20
    apt remove --purge -y snapd-core22
    apt remove --purge -y snapd-core24
}

# Function to prevent snap from being reinstalled
prevent_snap_reinstall() {
    echo "Preventing Snap from being reinstalled..."
    
    # Create a blacklist for snap packages
    echo "Package: snapd
Pin: release a=*
Pin-Priority: -1

Package: gnome-software-plugin-snap
Pin: release a=*
Pin-Priority: -1

Package: snapd-xdg-open
Pin: release a=*
Pin-Priority: -1

Package: snapd-core
Pin: release a=*
Pin-Priority: -1

Package: snapd-core20
Pin: release a=*
Pin-Priority: -1

Package: snapd-core22
Pin: release a=*
Pin-Priority: -1

Package: snapd-core24
Pin: release a=*
Pin-Priority: -1" > /etc/apt/preferences.d/nosnap.pref
    
    # Remove snap from apt preferences if it exists
    rm -f /etc/apt/preferences.d/snapd.pref
    
    # Add snap to hold list to prevent reinstallation
    echo "snapd hold" | dpkg --set-selections
    echo "gnome-software-plugin-snap hold" | dpkg --set-selections
    echo "snapd-xdg-open hold" | dpkg --set-selections
    echo "snapd-core hold" | dpkg --set-selections
    echo "snapd-core20 hold" | dpkg --set-selections
    echo "snapd-core22 hold" | dpkg --set-selections
    echo "snapd-core24 hold" | dpkg --set-selections
    
    # Remove snap from package manager if it's in the list
    for pkg in snapd gnome-software-plugin-snap snapd-xdg-open snapd-core snapd-core20 snapd-core22 snapd-core24; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            echo "Removing $pkg if it's installed..."
            apt remove --purge -y "$pkg" 2>/dev/null || true
        fi
    done
}

# Function to clean up apt cache
clean_apt_cache() {
    echo "Cleaning up apt cache..."
    apt autoremove -y
    apt autoclean
    apt clean
}

# Function to check if snap is completely removed
check_snap_removal() {
    echo "Checking if Snap is completely removed..."
    
    # Check if snapd service is running
    if systemctl is-active --quiet snapd; then
        echo "Warning: Snapd service is still running"
        return 1
    fi
    
    # Check for snap packages
    if dpkg -l | grep -q "snapd"; then
        echo "Warning: Snap packages still found"
        return 1
    fi
    
    # Check for snap directories
    if [ -d "/var/lib/snapd" ] || [ -d "/var/snap" ] || [ -d "/snap" ]; then
        echo "Warning: Snap directories still exist"
        return 1
    fi
    
    echo "Snap has been successfully removed."
    return 0
}

# Function to disable snapd service permanently
disable_snapd_service() {
    echo "Disabling Snap services permanently..."
    
    # Disable snapd services
    systemctl disable snapd
    systemctl disable snapd.apparmor
    systemctl disable snapd.seeded
    systemctl disable snapd.autoimport
    systemctl disable snapd.recovery
    systemctl disable snapd.system-shutdown
    systemctl disable snapd.socket
    systemctl disable snapd.snap-repair.service
    systemctl disable snapd.snap-repair.timer
    
    # Mask snapd services to prevent startup
    systemctl mask snapd
    systemctl mask snapd.apparmor
    systemctl mask snapd.seeded
    systemctl mask snapd.autoimport
    systemctl mask snapd.recovery
    systemctl mask snapd.system-shutdown
    systemctl mask snapd.socket
    systemctl mask snapd.snap-repair.service
    systemctl mask snapd.snap-repair.timer
}

# Function to remove snap from update manager
remove_snap_from_update_manager() {
    echo "Removing Snap from update manager..."
    
    # Remove snap from the update manager
    if command_exists apt-mark; then
        apt-mark hold snapd
        apt-mark hold gnome-software-plugin-snap
        apt-mark hold snapd-xdg-open
        apt-mark hold snapd-core
        apt-mark hold snapd-core20
        apt-mark hold snapd-core22
        apt-mark hold snapd-core24
    fi
}

# Function to remove snap from system paths
remove_snap_from_paths() {
    echo "Removing Snap from system paths..."
    
    # Remove snap from PATH if it exists
    if grep -q "snap" /etc/environment; then
        sed -i '/snap/d' /etc/environment
    fi
    
    # Remove snap from bashrc if it exists
    if grep -q "snap" ~/.bashrc; then
        sed -i '/snap/d' ~/.bashrc
    fi
    
    # Remove snap from profile if it exists
    if grep -q "snap" /etc/profile; then
        sed -i '/snap/d' /etc/profile
    fi
}

# Function to update package lists
update_package_lists() {
    echo "Updating package lists..."
    apt update
}

# Main execution
main() {
    echo "Starting complete Snap removal process..."
    echo ""
    
    # Stop services first
    stop_snap_services
    
    # Remove packages
    remove_snap_packages
    
    # Remove dependencies
    remove_snap_dependencies
    
    # Prevent reinstallation
    prevent_snap_reinstall
    
    # Disable services permanently
    disable_snapd_service
    
    # Remove from update manager
    remove_snap_from_update_manager
    
    # Remove from system paths
    remove_snap_from_paths
    
    # Clean up
    clean_apt_cache
    
    # Update package lists
    update_package_lists
    
    # Check removal
    if check_snap_removal; then
        echo ""
        echo "=============================================="
        echo "SUCCESS: Snap has been completely removed!"
        echo "=============================================="
        echo ""
        echo "The following actions were performed:"
        echo "1. Stopped all Snap services"
        echo "2. Removed all Snap packages"
        echo "3. Removed Snap dependencies"
        echo "4. Prevented Snap reinstallation"
        echo "5. Disabled Snap services permanently"
        echo "6. Cleaned up package cache"
        echo ""
        echo "You may need to reboot your system for all changes to take effect."
        echo ""
    else
        echo ""
        echo "=============================================="
        echo "WARNING: Some Snap components may still be present"
        echo "=============================================="
        echo ""
        echo "Please check the output above for warnings and consider manual removal."
        echo ""
    fi
    
    echo "Snap removal process completed."
}

# Run main function
main