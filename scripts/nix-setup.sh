# Script to install nixos in an 
# Erase my darlings -style configuration
# Root is erased on boot.

function prompt {
	read -n 1 -srp $'Is this correct? (y/N) ' key
	echo
	if [ "$key" != 'y' ]; then 
        exit
    fi
}

function get_user_info {
    # Gather the 1.Username, 2.Password & 3.Hostname
    # 1. Username
    echo "Lets set the username"
    DEFAULT_UNAME=$(grep -oP 'user =.*?"\K[^"]*' "$NIXDIR/users.nix")
    echo "Default username is: $DEFAULT_UNAME"

    read -n 1 -srp $'Is this ok? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                             
        read -rp "Enter New Username: " UNAME
        echo "The username is: $UNAME"  
        prompt
    else 
        UNAME=$DEFAULT_UNAME
    fi

    # 2. Password
    echo
    echo "Now lets set the user password"
    read -srp "Enter New User Password: " PASS1
    echo 
    read -srp "Password (again): " PASS2
    if  [[ "$PASS1" != "$PASS2" ]]; then
        echo "Passwords do not match! Exiting ..."
        exit
    fi

    # 3. Hostname
    echo
    echo
    echo "Now lets set the Hostname"
    DEFAULT_HOST=$(grep -oP 'myhostname =.*?"\K[^"]*' "$NIXDIR/myparams.nix")
    echo "Default Hostname is: $DEFAULT_HOST"
    read -n 1 -srp $'Is this ok? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then
      read -rp "Enter New Hostname: " HOST
      echo "The New Hostname is: $HOST"  
      prompt
    else
      HOST=$DEFAULT_HOST
    fi


    # 4. SSH Key
    echo
    echo
    echo "Now lets set the SSH key"
    DEFAULT_SSHKEY=$(grep -oP 'mysshkey =.*?"\K[^"]*' "$NIXDIR/myparams.nix")
    SSHKEY=$DEFAULT_SSHKEY
    echo "Current SSH Key is: $DEFAULT_SSHKEY"
    read -n 1 -srp $'Is this ok? (Y/n) ' key
    while [ "$key" == "n" ]
    do
      echo
      read -rp "Enter an SSH Key for user $UNAME: " SSHKEY
      echo "The New SSH Key is: $SSHKEY"  
      read -n 1 -srp $'Is this ok? (Y/n) ' key
    done

    # Write out the username 
    sed -i "s#myusername = \".*\";#myusername = \"${UNAME}\";#" "$NIXDIR/myparams.nix"
    # Write out the hostname 
    sed -i "s#myhostname = \".*\"#myhostname = \"${HOST}\";#" "$NIXDIR/myparams.nix"
    # Write out the ssh-key 
    sed -i "s#mysshkey = \".*\";#mysshkey = \"${SSHKEY}\";#" "$NIXDIR/myparams.nix"
}


function build_file_system {
    echo "Making File system"
    DISK=/dev/vda
    echo
    echo "Drive to erase and install nixos on is: $DISK"
    read -n 1 -srp $'Is this ok? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                             
        lsblk
        read -rp "Enter New Disk: " DISK
        echo "Nixos will be installed on: $DISK"  
        prompt
    fi

    echo "WARNING - About to erase $DISK and install NixOS."
    prompt

    nix run github:nix-community/disko -- --mode zap_create_mount "../etc/nixos/disko-config.nix" --arg disks '[ "$DISK" ]'


    # parted "$DISK" -- mklabel gpt
    # echo "Making 1Gb ESP boot on partition 1"
    # parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
    # parted "$DISK" -- set 1 boot on
    # mkfs.vfat "$DISK"1

    # echo "Making 8Gb Swap on partition 2"
    # parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
    # mkswap -L Swap "$DISK"2
    # swapon "$DISK"2

    # echo "Making the rest BTRFS on partition 3"
    # parted "$DISK" -- mkpart primary 9GiB 100%
    # mkfs.btrfs -f -L Butter "$DISK"3

    # echo "Making BTRFS subvolumes"
    # mount "$DISK"3 /mnt
    # btrfs subvolume create /mnt/root
    # btrfs subvolume create /mnt/home
    # btrfs subvolume create /mnt/nix
    # btrfs subvolume create /mnt/persist
    # btrfs subvolume create /mnt/log
    # btrfs subvolume create /mnt/machines
    # btrfs subvolume create /mnt/portables

    # We then take an empty *readonly* snapshot of the root subvolume,
    # which we'll eventually rollback to on every boot.
    echo "Making empty snapshot of root"
    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

    # umount /mnt

    # Mount the directories

    # mount -o subvol=root,compress=zstd,noatime "$DISK"3 /mnt

    # mkdir /mnt/home
    # mount -o subvol=home,compress=zstd,noatime "$DISK"3 /mnt/home

    # mkdir /mnt/nix
    # mount -o subvol=nix,compress=zstd,noatime "$DISK"3 /mnt/nix

    # mkdir /mnt/persist
    # mount -o subvol=persist,compress=zstd,noatime "$DISK"3 /mnt/persist

    # mkdir -p /mnt/var/log
    # mount -o subvol=log,compress=zstd,noatime "$DISK"3 /mnt/var/log

    # mkdir -p /mnt/var/lib/machines
    # mount -o subvol=machines,compress=zstd,noatime "$DISK"3 /mnt/var/lib/machines

    # mkdir -p /mnt/var/lib/portables
    # mount -o subvol=portables,compress=zstd,noatime "$DISK"3 /mnt/var/lib/portables

    # don't forget this!
    # mkdir /mnt/boot
    # mount "$DISK"1 /mnt/boot

    echo "Disk configuration complete!"
    echo
}

function generate_config {
    # create configuration
    echo "Generating Config"
    # nixos-generate-config --root /mnt
    # For disko we generate a config with the --no-filesystems option
    nixos-generate-config --no-filesystems --root /mnt
    echo

    # Copy over our nixos config
    echo "Copying over our nixos configs"
    # Copy config files to new install

    cp "$NIXDIR"/* /mnt/etc/nixos
    # Copy these files into persist volume (we copy from destination to include the hardware.nix)
    mkdir -p /mnt/persist/etc/nixos
    cp /mnt/etc/nixos/* /mnt/persist/etc/nixos/


    echo "Copying over script files"
    mkdir -p /mnt/persist/scripts
    cp "$SCRIPTDIR"/* /mnt/persist/scripts

    # Write the password we entered earlier
    mkdir -p /mnt/persist/passwords
    mkpasswd -m sha-512 "$PASS1" > /mnt/persist/passwords/user
    echo "Password file is:"
    cat /mnt/persist/passwords/user
}

# Make script independent of which dir it was run from
SCRIPTDIR=$(dirname "$0")
NIXDIR="$SCRIPTDIR/../etc/nixos"

get_user_info
build_file_system
generate_config

echo "To install the system run: "
echo "nixos-install"
echo



