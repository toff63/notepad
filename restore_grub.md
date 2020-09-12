---
date: 2020-09-12
tags: linux grub
---

## Problem

Windows updated itself and put its bootloader to start the computer. This is very annoying as you don't have the grub menu anymore and cannot choose to start your linux distribution.

## Background

On modern computers, boot is managed by a EFI partition. On linux it is mounted on `/boot/efi`. This is where every OS put its efi files to start itself. When the system start, it looks for an efi file to execute. The problem is that windows won't show any menu and boot its own: `/boot/efi/EFI/Microsoft/Boot/bootmgfw.efi`. In my case, the ubuntu one was already there but for some reason the firmware would not want to boot from it. 
To mount the efi partition in ubuntu: `mount /dev/sda1 /boot/efi` if the efi partition is `/dev/sda1`.
When installing grub, the process will try to update the firmware variables. Those, on my ubuntu are in `/sys/firmware/efi/efivars`. You can mount it, but you need to specify the filesystem type: `mount -t efivarfs efivarfs /sys/firmware/efi/efivars`. This is not mandatory to do it as grub will start even if it fails to write there.

On the windows side, you can see the boot management setup by running as admin in a terminal: `bcdedit`. You can first try to edit the efi file being loaded by running `bcdedit /set {bootmgr} path /boot/efi/EFI/ubuntu/grubx64.efi`. However, if it fails to load the file, which was my case, you will have to stop the boot from loading, choose the rescue your windows and put it back to its initial value, so you can use windows to download a linux live iso and proceed with the solution below. 

## Solution

First, you need to create a bootable usb drive with a linux live.
Restart your computer and boot on your usb drive.

### Mount your installed ubuntu partitions

We need to mount the main ubuntu partitions and map the device partitions in order to run the `grub-install` command successfully.
1. Find out which is the linux root partition on your disk using Gparted or running the `lsblk` command in a terminal
2. Mount the root partition in `/mnt`:  `sudo mount /dev/sdaX /mnt`
3. Bind the device files `/dev`: `sudo mount –bind /dev /mnt/dev`
4. Bind pseud terminal slave (pts) `/dev/pts`: `sudo mount –bind /dev/pts /mnt/dev/pts`
5. Bind processes `/dev/proc`: `sudo mount –bind /proc /mnt/proc`
6. Bind sys files: `sudo mount –bind /sys /mnt/sys`
7. Get root access to your root partition: `sudo chroot /mnt`

### Re-install grub

Just run `grub-install /dev/sda && update-grub`. If it complains about not being able to write variable, no worries. It just means it did not have acccess to your firmware file. It does not prevent grub from booting up.

You now want to restart your computer, grub menu should appear this time. Once logged in, re-run `grub-install /dev/sda && update-grub`. This time, there should be no warnings.

## Reference
[How do I recover GRUB after installing Windows?](How do I recover GRUB after installing Windows?)
[BCD System Store Settings for UEFI](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcd-system-store-settings-for-uefi)
