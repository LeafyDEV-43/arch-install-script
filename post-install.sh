#!/bin/bash
# post-install.sh -- Runs inside chroot
set -e

USERNAME=$1
PASSWORD=$2

# Timezone & locale
echo ">>> Setting timezone..."
ln -sf /usr/share/zoneinfo/Africa/Lusaka /etc/localtime
hwclock --systohc

echo ">>> Configuring locale..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname and hosts
echo "archvm" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\tarchvm.localdomain archvm" > /etc/hosts

# Root password
echo "root:$PASSWORD" | chpasswd

# Create user
echo ">>> Creating user $USERNAME..."
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Install and enable services
echo ">>> Enabling services..."
systemctl enable NetworkManager
systemctl enable ly

# Bootloader
echo ">>> Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Autostart neofetch
mkdir -p /home/$USERNAME/.config/autostart
cat <<EOF > /home/$USERNAME/.config/autostart/neofetch.desktop
[Desktop Entry]
Type=Application
Exec=kitty --hold -e neofetch
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Neofetch
Comment=Run neofetch on login
EOF

chown -R $USERNAME:$USERNAME /home/$USERNAME

echo ">>> Post-install complete! Ready to reboot."
exit
