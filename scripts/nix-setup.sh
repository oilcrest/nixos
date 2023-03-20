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

# Make script independent of which dir it was run from
SCRIPTDIR=$(dirname "$0")
NIXDIR="$SCRIPTDIR/../nixos/"

# Gather the Username, Password & Hostname

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
DEFAULT_HOST=$(grep -oP 'hostName =.*?"\K[^"]*' "$NIXDIR/configuration.nix")
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

# Write out the username 
sed "s/user = \"nixuser\"/user = ${UNAME}/" "$NIXDIR"/users.nix
# Write out the hostname 
sed "s/hostName = \"nixos\"/hostName = ${HOST}/" "$NIXDIR"/configuration.nix


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

parted "$DISK" -- mklabel gpt
echo "Making 1Gb ESP boot on partition 1"
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

echo "Making 8Gb Swap on partition 2"
parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
mkswap -L Swap "$DISK"2
swapon "$DISK"2

echo "Making the rest BTRFS on partition 3"
parted "$DISK" -- mkpart primary 9GiB 100%
mkfs.btrfs -f -L Butter "$DISK"3

echo "Making BTRFS subvolumes"
mount "$DISK"3 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log
btrfs subvolume create /mnt/machines
btrfs subvolume create /mnt/portables

# We then take an empty *readonly* snapshot of the root subvolume,
# which we'll eventually rollback to on every boot.
echo "Making empty snapshot of root"
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

umount /mnt

# Mount the directories

mount -o subvol=root,compress=zstd,noatime "$DISK"3 /mnt

mkdir /mnt/home
mount -o subvol=home,compress=zstd,noatime "$DISK"3 /mnt/home

mkdir /mnt/nix
mount -o subvol=nix,compress=zstd,noatime "$DISK"3 /mnt/nix

mkdir /mnt/persist
mount -o subvol=persist,compress=zstd,noatime "$DISK"3 /mnt/persist

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime "$DISK"3 /mnt/var/log

mkdir -p /mnt/var/lib/machines
mount -o subvol=machines,compress=zstd,noatime "$DISK"3 /mnt/var/lib/machines

mkdir -p /mnt/var/lib/portables
mount -o subvol=portables,compress=zstd,noatime "$DISK"3 /mnt/var/lib/portables

# don't forget this!
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot

echo "Disk configuration complete!"
echo

# create configuration
echo "Generating Config"
nixos-generate-config --root /mnt
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



echo "To install the system run: "
echo "nixos-install"
echo



