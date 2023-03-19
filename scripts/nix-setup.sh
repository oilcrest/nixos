# read password twice
echo "First lets set the user password"
read -s -p "Enter New User Password: " p1
echo 
read -s -p "Password (again): " p2

if  [[ "$p1" != "$p2" ]]; then
    echo "Passwords do not match! Exiting ..."
    exit
fi

mypass=$(mkpasswd -m sha-512 "$p1")
echo
FILE="/etc/nixos/users.nix"
echo "Writing password to $FILE"
sed -i "s,initialHashedPassword = \".*\";$,initialHashedPassword = \""$mypass"\";," "$FILE" 

FILE="/persist/etc/nixos/users.nix"
echo "Writing password to $FILE"
sed -i "s,initialHashedPassword = \".*\";$,initialHashedPassword = \""$mypass"\";," "$FILE" 


DISK=/dev/vda

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 boot on
mkfs.vfat "$DISK"1

# As I intend to use this VM on Proxmox, I will not encrypt the disk

parted "$DISK" -- mkpart Swap linux-swap 1GiB 9GiB
mkswap -L Swap "$DISK"2
swapon "$DISK"2

parted "$DISK" -- mkpart primary 9GiB 100%
mkfs.btrfs -f -L Butter "$DISK"3

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

# create configuration
nixos-generate-config --root /mnt


# Copy over our nixos config
echo "Copying over our nixos configs"
# Copy config files to new install
# Make script independent of which dir it was run from
SPATH=$(dirname "$0")
cp "$SPATH"/../nixos/* /mnt/etc/nixos
# Copy these files into persist volume (we copy from destination to include the hardware.nix)
mkdir -p /mnt/persist/etc/nixos
cp /mnt/etc/nixos/* /mnt/persist/etc/nixos/

echo "To install the system run: "
echo "nixos-install"
echo



