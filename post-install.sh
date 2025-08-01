#!/bin/bash
set -e

USERNAME="$1"
PASSWORD="$2"

echo ">>> Updating system and installing GUI packages..."
pacman -Syu --noconfirm
pacman -S --noconfirm plasma kde-applications ly kitty dolphin firefox \
    neovim btop mpv code neofetch

echo ">>> Creating user and setting password..."
useradd -m -G wheel "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo ">>> Enabling essential services..."
systemctl enable NetworkManager
systemctl enable ly
systemctl set-default graphical.target

echo ">>> Setting hostname and locale..."
echo "$USERNAME-PC" > /etc/hostname
ln -sf /usr/share/zoneinfo/Africa/Lusaka /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo ">>> Done! Exit and reboot when ready."
