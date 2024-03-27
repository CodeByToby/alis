#!/bin/env bash

source scripts/misc/pretty-printing.sh

export VARIABLE_FILE="scripts/misc/env-variables.conf"

# FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - #

function checks
{
    # UEFI check 
    if [ "$(cat /sys/firmware/efi/fw_platform_size)" != "64" ]; then
         print_error "Boot Type Is Not x64 UEFI!"
         exit 1
    fi

    # Internet check
    if [ "$(ping -qc 1 google.com >/dev/null)" ]; then
    	 print_error "No Internet Connection!"
    	 exit 1
    fi

    # root check
    if [ "$(whoami)" != "root" ]; then
        print_error "Not a 'root' user!"
        exit 1
    fi

    # arch check
    if [ ! -e /etc/arch-release ]; then
        print_error "Not on Arch Linux!"
        exit 1
    fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - SCRIPT. - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - BEGIN - - - - - - - - - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

checks

clear
setfont ter-128b

trap "rm $VARIABLE_FILE" EXIT # launches code on EXIT and INT

set -o errexit # exit on error
scripts/parse-config-file.sh # assess all variables are correct, add some derived variables
set +o errexit

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

# trap "" INT

# run first script
echo "YOU ARE ABOUT TO RUN THE FIRST SCRIPT TITLED \"0--setup.sh\"."
echo -n "PRESS ANY BUTTON TO CONTINUE... "; read -n1; clear

scripts/0--setup.sh |& tee 0--setup.log

# run second script
echo "YOU ARE ABOUT TO RUN THE SECOND SCRIPT TITLED \"1--install-base-system.sh\"."
echo -n "PRESS ANY BUTTON TO CONTINUE... "; read -n1; clear

scripts/1--install-base-system.sh |& tee 1--install-base-system.log

# run third script
if [[ "$INSTALL_GRAPHICAL_ENV" == "yes" ]]; then
    echo "YOU ARE ABOUT TO RUN THE THIRD SCRIPT TITLED \"2--graphical-environment.sh\"."
    echo -n "PRESS ANY BUTTON TO CONTINUE... "; read -n1; clear
    
    scripts/2--graphical-environment.sh |& tee 2--graphical-environment.log
fi

# run fourth script
echo "YOU ARE ABOUT TO RUN THE FOURTH SCRIPT TITLED \"3--configuration-chroot.sh\"."
echo -n "PRESS ANY BUTTON TO CONTINUE... "; read -n1; clear

cp scripts/misc/pretty-printing.sh /mnt

arch-chroot /mnt \
    env $(cat "$VARIABLE_FILE") \
    scripts/3--configuration-chroot.sh \
    |& tee 3--configuration-chroot.log

# clean-up
cp ./install-script.conf /mnt/home/"$USERNAME"/

umount -A --recursive /mnt

exit 0

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #