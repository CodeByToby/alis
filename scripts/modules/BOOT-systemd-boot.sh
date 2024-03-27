print_info "Enabling bootloader (systemd-boot)..."

bootctl install --root=/mnt/ # enable systemd-boot

print_info "Configuring bootloader..."

: > /mnt/boot/loader/loader.conf # clear file
cat <<EOF >>/mnt/boot/loader/loader.conf
default arch.conf
timeout 0
console-mode max
editor no
EOF

print_info "Adding Arch Linux entry..."

[ "$MICROCODE" ] && MICROCODE_INITRD="initrd /$MICROCODE.img"
ROOT_PARTITION_UUID="$(lsblk -dno UUID "$ROOT_PARTITION")"

cat <<EOF >>/mnt/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-$KERNEL
$MICROCODE_INITRD
initrd /initramfs-$KERNEL.img
options root="UUID=$ROOT_PARTITION_UUID" rw
EOF

print_info "Updating bootloader..."

bootctl update --root=/mnt/