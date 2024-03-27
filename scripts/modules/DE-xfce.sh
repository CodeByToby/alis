print_info "Installing xfce..."

pacman --noconfirm --needed -S xorg-server --root /mnt 
pacman --noconfirm --needed -S xfce4 xfce4-goodies gvfs --root /mnt 

print_info "Setting up greetd..."

pacman --noconfirm --needed -S greetd greetd-tuigreet --root /mnt
systemctl enable greetd.service --root=/mnt/

sed -i 's|agreety --cmd /bin/sh|tuigreet --cmd startxfce4 --remember --asterisks|' /mnt/etc/greetd/config.toml

print_info "Installing and setting up pulseaudio..."

pacman --noconfirm --needed -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pavucontrol --root /mnt
pacman --noconfirm --needed -S alsa-utils --root /mnt

# Unmute ALSA channels
arch-chroot /mnt amixer sset Master unmute
arch-chroot /mnt amixer sset Speaker unmute
arch-chroot /mnt amixer sset Headphone unmute
# Surround sound
arch-chroot /mnt amixer sset Front unmute
arch-chroot /mnt amixer sset Surround unmute
arch-chroot /mnt amixer sset Center unmute
arch-chroot /mnt amixer sset LFE unmute
arch-chroot /mnt amixer sset Side unmute