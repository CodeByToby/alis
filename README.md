# ALIS: Arch Linux Installation Script

The scripts' main purpose is the installation of the Arch Linux distribution and system. The program will configure internet, format a disk, install necessary software and more (detailed list down below).

As of March 2024, the installation script may not work as intended, especially when it comes to KDE installation and set-up.

# Usage

Configure the *install-script.conf* according to your preferences, or leave some variables empty and interactively choose/input during the install process.

After the configuration, run the *install-script.sh*, fill out the necessary variables from the last step, wait for a while, then enjoy your new Arch Linux system!

# Functionality

The full functionality scope of the program include:

- Formatting a disk and creating partitions;
- Choosing between a swap file, partition or no swap;
- Configuring internet;
- Installing base Arch system, including the bootloader (of user's choice);
- Setting locale, timezone and keymap for the console;
- Configuring pacman post-install.

And additional functionality that the user can opt out from:

- Adding a user;
- Setting up the bluetooth and drivers, depending on the graphics card;
- Installing a DE -- graphical environment;
- Installing custom software.
