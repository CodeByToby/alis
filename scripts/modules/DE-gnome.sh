print_info "Installing Gnome..."

pacman --noconfirm --needed -S gnome gnome-extra --root /mnt

print_info "Setting up GDM..."

pacman --noconfirm --needed -S gdm --root /mnt 
systemctl enable gdm.service --root=/mnt/ 