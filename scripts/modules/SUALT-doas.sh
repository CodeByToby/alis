print_info "Configuring doas..."

pacman --noconfirm --needed -S opendoas --root /mnt

cat <<EOF >>/mnt/etc/doas.conf
permit setenv { PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin } :wheel
permit setenv { XAUTHORITY LANG LC_ALL } :wheel

EOF