print_info "Installing and enabling network manager (NetworkManager)..."

pacman --noconfirm --needed -S networkmanager --root /mnt
systemctl enable NetworkManager.service --root=/mnt/