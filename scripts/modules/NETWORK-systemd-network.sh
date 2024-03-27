print_info "Enabling network manager (systemd-network)..."

systemctl enable systemd-resolved.service --root=/mnt/
systemctl enable systemd-networkd.service --root=/mnt/

print_info "Configuring a wired ethernet network..."

ETHERNET_ID="$(networkctl list 2>/dev/null | grep ether | awk '{ print $2 }' | grep -v v | head -1)"

cat <<EOF >>/mnt/etc/systemd/network/20-wired.network
[Match]
Name=$ETHERNET_ID

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes
EOF

print_info "Configuring systemd-resolve..."

ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf