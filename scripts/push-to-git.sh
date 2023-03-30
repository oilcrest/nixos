#!/usr/bin/env bash
# [ "$(id -u)" != 0 ] && exec sudo "$0"
# set -euo pipefail

echo "Script to push config files to git folder"


GITDIR="/persist/git"
CONDIR="/persist/"

# Make sure git folder is up-to-date
cd $GITDIR
git pull > /dev/null # git pull silently


# Which Config Files to keep in sync
files=(
  etc/nixos/configuration.nix
  etc/nixos/impermanence.nix
  etc/nixos/packages.nix
  etc/nixos/users.nix
  etc/nixos/vim.nix
  scripts/changepass.sh
  scripts/cruft.sh
  scripts/nix-setup.sh
  scripts/pull-from-git.sh
  scripts/push-to-git.sh
)

for f in "${files[@]}"
do
  A="$CONDIR/$f"
  B="$GITDIR/$f"

  if [[ "$(diff $A $B)" ]]; then
    clear
    diff $A $B 
    echo
    echo "File $f differs" 
    echo "The diff is as above."
    read -n 1 -srp $'Do you wish to push to git directory(y/N)? ' key
    echo
    if [ "$key" == 'y' ]; then
      cp $A $B
      chown 1000:users $B
    fi
  fi
done
echo "Files pushed to git directory"
read -n 1 -srp $'Do you wish to push the files to github (y/N)? ' key
echo
if [ "$key" == 'y' ]; then
  echo "Pushing files to github ..."
  cd $GITDIR
  git add .
  read -p "Enter a commit message: " MESSAGE
  # get a commit message
  git commit -m "'$MESSAGE'"
  git push
  echo "Done!"
fi



