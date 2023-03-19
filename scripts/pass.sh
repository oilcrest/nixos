# read password twice
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


