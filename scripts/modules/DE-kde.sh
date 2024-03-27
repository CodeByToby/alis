print_info "Installing KDE..."

KDE_PKGS=""

if [[ "$1" == "wayland" ]]; then 
    KDE_PKGS="plasma-wayland-session"
elif [[ "$1" == "xorg" ]]; then
    KDE_PKGS="xorg-server"
fi

pacman --noconfirm --needed -S plasma "$KDE_PKGS" --root /mnt

print_info "Setting up SDDM..."

pacman --noconfirm --needed -S sddm --root /mnt 
systemctl enable sddm.service --root=/mnt/
