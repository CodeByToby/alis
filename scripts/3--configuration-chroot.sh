#!/bin/env bash

source "$VARIABLE_FILE"
source pretty-printing.sh

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function pacman_configuration
{
    print_info "Configuring pacman for the new system..."

    sed -i 's/^#Color/Color/' /etc/pacman.conf
    sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
    sed -i '/\[multilib\]/,+1s/^#//' /etc/pacman.conf

    # update database for multilib
    pacman --noconfirm --needed -Sy

    print_milestone "Configured pacman!"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

pacman_configuration

if [ "$ADDITIONAL_SOFTWARE" ]; then
    print_info "Installing additional software..."

    # ADDITIONAL_SOFTWARE is not quoted in order to treat multiple packages as separate
    pacman --noconfirm --needed -S $ADDITIONAL_SOFTWARE

    print_milestone "Installed software!"
fi

if [[ "$BOOTLOADER" == "grub" ]]; then
    print_info "Configuring GRUB..."

    grub-mkconfig -o /boot/grub/grub.cfg

    print_milestone "Configured GRUB!"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #