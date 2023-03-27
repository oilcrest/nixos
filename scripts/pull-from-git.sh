#!/usr/bin/env bash
# [ "$(id -u)" != 0 ] && exec sudo "$0"
# set -euo pipefail

echo "Script to pull in the latest configuration.nix from github"
cd /persist/git
git pull
CONDIR="/persist/etc/nixos/"
GITDIR="/persist/git/nixos/"

# Which Config Files to keep in sync
files=(
configuration.nix
# packages.nix
# users.nix
vim.nix
)

for f in "${files[@]}"
do
  A="$CONDIR/$f"
  B="$GITDIR/$f"
  if [[ ! "$(diff $A $B)" ]]; then
    echo "No update" && exit && exit
  else
    echo "git file has been updated!"
    echo "The diff is as follows:"
    diff $A $B 
    read -n 1 -srp $'Do you wish to replace original (y/N)? ' key
    echo
    if [ "$key" == 'y' ]; then
      sudo mv "$A" "$A.old"
      sudo cp "$B" "$A"
      echo "Config updated!"
      echo "To reconfigure run:"
      echo "sudo nixos-rebuild switch"
    fi
  fi
done
