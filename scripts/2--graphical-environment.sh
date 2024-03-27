#!/bin/env bash

source "$VARIABLE_FILE"
source scripts/misc/pretty-printing.sh

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function bluetooth_installation
{
    print_info "Cheking for bluetooth..."

    pacman --noconfirm --needed -S lshw
    local BTOOTH_CHECK="$(lshw | grep -i blue)"
    
    if [ "$BTOOTH_CHECK" ]; then
        print_info "Bluetooth detected. Installing bluetooth software..."

        pacman --noconfirm --needed -S bluez bluez-utils --root /mnt 

        # Check whether btusb (generic bluetooth driver) kernel module is loaded.
        if [ ! "$(lsmod | grep btusb)" ]; then
            print_info "Loading btusb module..."
            
            modprobe btusb
        fi

        print_info "Enabling bluetooth service..."

        systemctl enable bluetooth.service --root=/mnt/

        print_milestone "Configured bluetooth!"
    fi
}

function drivers_installation
{
    print_info "Installing necessary graphics drivers..."

    local GPU_TYPE="$(lspci -v | grep -E "(VGA|3D)")"
    local DRIVER_PKGS=""

    if grep -E "Radeon|AMD" <<< "$GPU_TYPE"; then
        DRIVER_PKGS="xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon"
    elif grep "Intel" <<< "$GPU_TYPE"; then
        DRIVER_PKGS="vulkan-intel lib32-vulkan-intel"
    elif grep -E "NVIDIA|GeForce" <<< "$GPU_TYPE"; then
        DRIVER_PKGS="xf86-video-nouveau"
    else
        DRIVER_PKGS="xorg-drivers"
    fi

    # DRIVER_PKG is not quoted in order to treat all packages as separate.
    pacman --noconfirm --needed -S mesa lib32-mesa $DRIVER_PKGS --root /mnt

    print_milestone "Installed graphics drivers!"
}

function desktop_environments_installation
{
    case $DE in
        xfce) source scripts/modules/DE-xfce.sh ;;
        kde-xorg) source scripts/modules/DE-kde.sh xorg ;;
        kde-wayland) source scripts/modules/DE-kde.sh wayland ;;
        gnome) source scripts/modules/DE-gnome.sh ;;
    esac

    # Home directories
    pacman --noconfirm --needed -S xdg-user-dirs --root /mnt
    xdg-user-dirs-update

    print_milestone "Set up a graphical environment!"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

drivers_installation
bluetooth_installation

[[ "$DE" != "none" ]] && \
    desktop_environments_installation

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #