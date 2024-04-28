#!/bin/env bash

source "$VARIABLE_FILE"
source scripts/misc/pretty-printing.sh

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function locale_timezone
{
	print_info "Linking timezone..."

	ln -sf /usr/share/zoneinfo/"$TIMEZONE" /mnt/etc/localtime
	arch-chroot /mnt hwclock --systohc # generate /etc/adjtime

	print_info "Generating locale..."

	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen # US/English locale
	# sed -i 's/^#pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /mnt/etc/locale.gen # Polish locale

	arch-chroot /mnt locale-gen

	print_info "Creating locale files..."

	echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

	echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
	echo "FONT=ter-128b" >> /mnt/etc/vconsole.conf

	print_milestone "Finished setting up locale!"
}

function users 
{
	if [ "$USERNAME" ]; then
		print_info "Adding $USERNAME..."

		groupadd libvirt --root /mnt
		useradd -mG input,audio,video,storage,libvirt,wheel -s /bin/bash "$USERNAME" --root /mnt

		print_info "Changing user password..."

		[ "$USER_PASSWORD" ] && echo "${USERNAME}:${USER_PASSWORD}" | chpasswd --root /mnt
	fi

	print_info "Changing root password..."

	[ "$ROOT_PASSWORD" ] && echo "root:${ROOT_PASSWORD}" | chpasswd --root /mnt

	case $SU_ALTERNATIVE in
		sudo) source scripts/modules/SUALT-sudo.sh ;;
		doas) source scripts/modules/SUALT-doas.sh ;;
	esac

	print_milestone "Finished setting up users!"
}

function bootloader
{
	case $BOOTLOADER in
		grub) source scripts/modules/BOOT-grub.sh ;;
		systemd-boot) source scripts/modules/BOOT-systemd-boot.sh ;;
	esac

	print_milestone "Configured bootloader!"
}

function network
{
	case $NETWORKING in
		networkmanager) source scripts/modules/NETWORK-networkmanager.sh ;;
		systemd-network) source scripts/modules/NETWORK-systemd-network.sh ;;
	esac

	print_info "Setting up /etc/hostname..."

	echo "$HOSTN" > /mnt/etc/hostname

	print_milestone "Configured networking!"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

locale_timezone
users

bootloader
network

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
