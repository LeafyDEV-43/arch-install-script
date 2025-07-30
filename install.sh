#!/bin/bash
# install.sh -- Run this inside the Arch ISO
set -e

DISK="/dev/sda"
USERNAME="drakie"
PASSWORD="1347"

# Time to party!
echo ">>> Setting time..."
timedatectl set-ntp true

# Partition the disk
echo ">>> Wiping and partitioning $DISK..."
parted --script $DISK mklabel gpt
parted --script $DISK mkpart ESP fat32 1MiB 513MiB
parted --script $DISK set 1 esp on
parted --script $DISK mkpart primary ext4 513MiB 100%

# Format
mkfs.fat -F32 ${DISK}1
mkfs.ext4 ${DISK}2

# Mount
mount ${DISK}2 /mnt
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi

# Install base system
echo ">>> Installing base system..."
pacstrap /mnt base linux linux-firmware sudo grub efibootmgr networkmanager \
        plasma kde-applications ly kitty dolphin firefox neovim btop mpv neofetch code

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy post-install script
cp post-install.sh /mnt/root/
chmod +x /mnt/root/post-install.sh

# Chroot & finish
arch-chroot /mnt /root/post-install.sh "$USERNAME" "$PASSWORD"

# Cleanup
rm /mnt/root/post-install.sh
umount -R /mnt
echo "Yayy! Arch installed! You may now reboot."
reboot
