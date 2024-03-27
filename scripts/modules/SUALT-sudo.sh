print_info "Configuring sudo..."

pacman --noconfirm --needed -S sudo --root /mnt

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers 