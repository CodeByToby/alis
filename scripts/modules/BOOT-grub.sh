print_info "Installing and enabling bootloader (GRUB)..."

pacman --noconfirm --needed -S grub efibootmgr --root=/mnt
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Configuration through 'grub-mkconfig' will occur in 3--configuration-chroot.sh script,
# due to the command not working properly when used as an argument with arch-chroot.