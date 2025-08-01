#!/bin/bash
# post-install.sh -- Runs inside chroot
set -e

USERNAME="$1"
PASSWORD="$2"

echo ">>> Updating system and installing GUI packages..."
pacman -Syu --noconfirm
pacman -S --noconfirm plasma kde-applications ly kitty dolphin firefox \
    neovim btop mpv code 

# Timezone & locale
echo ">>> Setting timezone..."
ln -sf /usr/share/zoneinfo/Africa/Lusaka /etc/localtime
hwclock --systohc

echo ">>> Configuring locale..."
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname and hosts
echo "$USERNAME-PC" > /etc/hostname
cat <<EOF > /etc/hosts \
127.0.0.1       localhost
::1             localhost
127.0.1.1       $USERNAME-PC.localdomain $USERNAME-PC
EOF

# Root password
echo ">>> Setting root password..."
echo "root:$PASSWORD" | chpasswd

# Create user
echo ">>> Creating user $USERNAME..."
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable services
echo ">>> Enabling services..."
systemctl enable NetworkManager
systemctl enable ly
systemctl set-default graphical.target

# Bootloader
echo ">>> Installing GRUB bootloader..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Fix home permissions
chown -R "$USERNAME:$USERNAME" /home/"$USERNAME"

echo ">>> Post-install complete! Ready to reboot."
exit
