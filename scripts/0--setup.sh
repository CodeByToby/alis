#!/bin/env bash

source "$VARIABLE_FILE"
source scripts/misc/pretty-printing.sh

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function partitioning
{
    print_info "Partitioning $DISK..."

    pacman -S --noconfirm --needed gptfdisk 

    umount -A --recursive /mnt 2>/dev/null # make sure everything is unmounted before we start

    wipefs -af "$DISK" # wipes signatures from disk 
    sgdisk -Zo "$DISK" # destroy MBR and GPT structures on disk

    if [[ "$SWAP" == "partition" ]]; then
        sgdisk --new 1::+1G --typecode=1:ef00 --change-name=1:'EFI System Partition' "$DISK"
        sgdisk --new 2::+"$SWAP_PARTITION_SIZE" --typecode=2:8200 --change-name=2:'Swap' "$DISK"
        sgdisk --new 3::-0 --typecode=3:8304 --change-name=3:'Root Partition' "$DISK"   
    else
        sgdisk --new 1::+1G --typecode=1:ef00 --change-name=1:'EFI System Partition' "$DISK"
        sgdisk --new 2::-0 --typecode=2:8304 --change-name=2:'Root Partition' "$DISK"   
    fi

    print_info "Informing OS of disk changes..."
    
    partprobe "$DISK"
}

function formatting
{
    print_info "Formatting partitions..."

    mkfs.ext4 "$ROOT_PARTITION"
    mkfs.fat -F32 "$EFI_PARTITION"
    [[ "$SWAP" == "partition" ]] && mkswap "$SWAP_PARTITION"
}

function mounting
{
    print_info "Mounting partitions..."

    mount "$ROOT_PARTITION" /mnt
    mount --mkdir "$EFI_PARTITION" /mnt/boot
    [[ "$SWAP" == "partition" ]] && swapon "$SWAP_PARTITION"
}

function disk_setup
{
    partitioning
    formatting
    mounting
   
    print_milestone "Set up $DISK!"

    lsblk; echo ''
}

function swap_file
{
    print_info "Setting up a swapfile..."

    arch-chroot /mnt dd if=/dev/zero of=/swapfile bs=1M count=8k status=progress # create 8 GiB swap file
    chmod 0600 /mnt/swapfile # read-write permissions for only the root user
    
    mkswap -U clear /mnt/swapfile
    swapon /mnt/swapfile

    print_milestone "Set up a swapfile!"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

loadkeys "$KEYMAP"
timedatectl set-ntp true # update system clock

sed -i 's/^#Color/Color/' /etc/pacman.conf # enable colored output
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf # enable parallel downloads
sed -i '/\[multilib\]/,+1s/^#//' /etc/pacman.conf # enable multilib

print_info "Generating mirrorlist..."    
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector --age 48 --fastest 10 --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
print_milestone "Generated mirrorlist!"

# Update arch keyrings to avoid problems with installing packages
print_info "Updating archlinux-keyring..."
pacman -Sy --noconfirm archlinux-keyring
pacman-key --init
print_milestone "Updated archlinux-keyring!"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

disk_setup

# MICROCODE variable is not quoted to prevent pacstrap breaking when variable is empty.
print_info "Installing base system packages..."
pacstrap -K /mnt base "$KERNEL" $MICROCODE linux-firmware man-db man-pages texinfo
print_milestone "installed Base system packages!"

[[ "$SWAP" == "file" ]] && swap_file

print_info "Genetating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
[[ "$SWAP" == "file" ]] && echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
print_milestone "Generated fstab!"

# - - - - - - - - - - - - - - -  - - - - - - - - - - - - - - - - - #
