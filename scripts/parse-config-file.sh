#!/bin/env bash

source scripts/misc/helper-functions.sh
source scripts/misc/pretty-printing.sh
source install-script.conf

: > "$VARIABLE_FILE"

shopt -s extglob # for extended pattern checking

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function partition_variables
{
    local ID=1
    [[ $DISK =~ nvme ]] && local NVME_P="p"

    set_variable "EFI_PARTITION" "${DISK}${NVME_P}$((ID++))"; 
    [[ "$SWAP" == "partition" ]] && \
        set_variable "SWAP_PARTITION" "${DISK}${NVME_P}$((ID++))"
    set_variable "ROOT_PARTITION" "${DISK}${NVME_P}$((ID++))"
}

function passwords
{
    if [ "$USERNAME" ]; then
        if [ -z "$USER_PASSWORD" ]; then
            print_select "Set a password for the user: $USERNAME"
            set_password "USER_PASSWORD"
            echo -ne "\n"
        else
            set_variable "USER_PASSWORD" "$USER_PASSWORD"
        fi
    fi

    if [ -z "$ROOT_PASSWORD" ]; then
        print_select "Set a password for the user: root"
        set_password "ROOT_PASSWORD"
        echo -ne "\n"
    else
        set_variable "ROOT_PASSWORD" "$ROOT_PASSWORD"
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# KERNEL
while [[ $KERNEL == !(linux|linux-lts|linux-zen|linux-hardened) ]]; do
    change_variable "KERNEL" "select" "linux linux-lts linux-zen linux-hardened"
done; set_variable "KERNEL" "$KERNEL"

# BOOTLOADER
while [[ $BOOTLOADER == !(grub|systemd-boot) ]]; do
    change_variable "BOOTLOADER" "select" "grub systemd-boot"
done; set_variable "BOOTLOADER" "$BOOTLOADER"

# NETWORKING
while [[ $NETWORKING == !(networkmanager|systemd-network) ]]; do
     change_variable "NETWORKING" "select" "systemd-network"
done; set_variable "NETWORKING" "$NETWORKING"

# MICROCODE
while [[ $MICROCODE == !(intel-ucode|amd-ucode|none|detect) ]]; do
    change_variable "MICROCODE" "select" "intel-ucode amd-ucode none detect"
done

if [[ "$MICROCODE" == "detect" ]]; then
    PROC_TYPE=$(lscpu | grep -E "GenuineIntel|AuthenticAMD")

    if [[ "$PROC_TYPE" =~ "GenuineIntel" ]]; then
        MICROCODE="intel-ucode"
    elif [[ "$PROC_TYPE" =~ "AuthenticAMD" ]]; then
        MICROCODE="amd-ucode"
    fi
fi; set_variable "MICROCODE" "$MICROCODE"

# SU_ALTERNATIVE
while [[ $SU_ALTERNATIVE == !(sudo|doas|none) ]]; do
    change_variable "SU_ALTERNATIVE" "select" "sudo doas none"
done; set_variable "SU_ALTERNATIVE" "$SU_ALTERNATIVE"

# DESKTOP ENVIRONMENT
while [[ $DE == !(xfce|kde-xorg|kde-wayland|gnome|none) ]]; do
    change_variable "DE" "select" "xfce kde-xorg kde-wayland gnome none"
done; set_variable "DE" "$DE"

if [[ "$DE" == "none" ]]; then
    print_select "You did not select a desktop environment. Do you want to install graphics drivers? (1/2)"

    select INSTALL_GRAPHICAL_ENV in yes no; do
        [ ! "$INSTALL_GRAPHICAL_ENV" ] && \
            continue
        
        export INSTALL_GRAPHICAL_ENV
        break
    done
else
    export INSTALL_GRAPHICAL_ENV="yes"
fi

# ADDITIONAL SOFTWARE
set_variable "ADDITIONAL_SOFTWARE" "$ADDITIONAL_SOFTWARE"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# DISK AND PARTITIONS
AVAILABLE_DISKS="$(lsblk -dnpo NAME)"
while [[ ! $AVAILABLE_DISKS =~ $DISK ]]; do
    change_variable "DISK" "select" "$AVAILABLE_DISKS"
done; set_variable "DISK" "$DISK"
partition_variables

# SWAP
while [[ $SWAP == !(partition|file|none) ]]; do
    change_variable "SWAP" "select" "partition file none"
done; set_variable "SWAP" "$SWAP"

if [[ "$SWAP" == "partition" ]]; then
    [ -z "$SWAP_PARTITION_SIZE" ] && SWAP_PARTITION_SIZE="8G"
    set_variable "SWAP_PARTITION_SIZE" "$SWAP_PARTITION_SIZE"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# USERNAME AND PASSWORDS 
set_variable "USERNAME" "${USERNAME,,}"
export USERNAME # for copying log files in install-script.sh
passwords

# HOSTNAME
set_variable "HOSTN" "${HOSTN,,}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# TIMEZONE
while [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; do
    change_variable "TIMEZONE" "input"
done; set_variable "TIMEZONE"

# KEYMAP
while ! localectl list-keymaps | grep -q "^$KEYMAP$"; do
    change_variable "KEYMAP" "input"
done; set_variable "KEYMAP" "$KEYMAP"

# PRINT VARIABLES AND CONFIRM
print_select "Are the variables correct? (Y/n)"
cat "$VARIABLE_FILE"
echo INSTALL_GRAPHICAL_ENV="$INSTALL_GRAPHICAL_ENV"
print_select "Are the variables correct? (Y/n)"
read -n1 OPTION
[[ $OPTION == +(n|N) ]] && exit 2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #